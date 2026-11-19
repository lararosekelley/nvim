--- Kubernetes helpers: kube-linter diagnostics, server-side dry runs, context and
--- schema version selection

local M = {}

--- kube-linter checks that point at broken manifests rather than style or hardening
---
--- The dangling-* checks need the other half of the pair in the same lint run, see
--- `lint_targets`.
---@type string[]
M.lint_checks = {
  "dangling-horizontalpodautoscaler",
  "dangling-ingress",
  "dangling-networkpolicy",
  "dangling-networkpolicypeer-podselector",
  "dangling-service",
  "dangling-servicemonitor",
  "duplicate-env-var",
  "invalid-target-ports",
  "liveness-port",
  "mismatching-selector",
  "readiness-port",
  "startup-port",
}

--- Context for :KubeDryRun, overriding kubectl's current context for this session only
---@type string|nil
M.context = nil

---@param bufnr integer
---@return string|nil
local function chart_root(bufnr)
  return vim.fs.root(bufnr, "Chart.yaml")
end

---@param bufnr integer
---@return boolean
local function is_manifest(bufnr)
  local has_api, has_kind = false, false

  for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
    has_api = has_api or line:match("^apiVersion:") ~= nil
    has_kind = has_kind or line:match("^kind:") ~= nil

    if has_api and has_kind then
      return true
    end
  end

  return false
end

--- Paths to lint for a buffer: its chart for helm templates, otherwise every yaml
--- file beside it, so a Service and its Deployment in sibling files see each other.
--- Not recursive, so saving a manifest at a repo root does not lint the whole repo.
---
---@param bufnr integer
---@return string[]|nil
function M.lint_targets(bufnr)
  if vim.bo[bufnr].filetype == "helm" then
    local root = chart_root(bufnr)

    return root and { root } or nil
  end

  if not is_manifest(bufnr) then
    return nil
  end

  local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))

  return vim.fn.glob(dir .. "/*.{yaml,yml}", false, true)
end

--- A repo's own kube-linter config wins over `lint_checks`
---
---@param bufnr integer
---@return string[]
local function lint_config_args(bufnr)
  local config = vim.fs.find({ ".kube-linter.yaml", ".kube-linter.yml" }, {
    upward = true,
    path = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)),
    stop = vim.fs.root(bufnr, ".git"),
  })[1]

  if config then
    return { "--config", config }
  end

  return { "--do-not-auto-add-defaults", "--include", table.concat(M.lint_checks, ",") }
end

--- Line of the `kind:` key of the document holding an object, since kube-linter
--- reports objects rather than positions
---
---@param bufnr integer
---@param kind string
---@param name string
---@return integer 1-based row
function M.object_row(bufnr, kind, name)
  local docs = { {} }

  for i, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
    local doc = docs[#docs]

    if line:match("^%-%-%-") then
      table.insert(docs, {})
    elseif line:match("^kind:") then
      doc.kind = vim.trim(line:gsub("^kind:", ""))
      doc.row = i
    elseif line:match("^metadata:") then
      doc.in_metadata = true
    elseif doc.in_metadata and not doc.name and line:match("^  name:") then
      doc.name = vim.trim(line:gsub("^  name:", ""):gsub("[\"']", ""))
    end
  end

  local fallback = nil

  for _, doc in ipairs(docs) do
    if doc.kind == kind then
      if doc.name == name then
        return doc.row
      end

      fallback = fallback or doc.row
    end
  end

  return fallback or 1
end

--- none-ls diagnostics source running kube-linter on save
---
---@return table
function M.kube_linter_source()
  local nls = require("null-ls")
  local h = require("null-ls.helpers")

  return {
    name = "kube_linter",
    method = nls.methods.DIAGNOSTICS_ON_SAVE,
    filetypes = { "yaml", "helm" },
    generator = h.generator_factory({
      command = "kube-linter",
      args = function(params)
        local args = { "lint", "--format", "json" }

        vim.list_extend(args, lint_config_args(params.bufnr))

        return vim.list_extend(args, M.lint_targets(params.bufnr) or {})
      end,
      format = "json",
      ignore_stderr = true,
      -- 1 means lint errors were found
      check_exit_code = function(code)
        return code <= 1
      end,
      timeout = 20000,
      runtime_condition = function(params)
        return vim.fn.executable("kube-linter") == 1 and M.lint_targets(params.bufnr) ~= nil
      end,
      on_output = function(params)
        local bufname = vim.uv.fs_realpath(params.bufname) or params.bufname
        local diagnostics = {}
        -- a clean run reports `"Reports": null`
        local reports = type(params.output) == "table" and params.output.Reports or nil

        for _, report in ipairs(type(reports) == "table" and reports or {}) do
          local object = report.Object or {}
          local path = vim.tbl_get(object, "Metadata", "FilePath")
          local k8s = object.K8sObject or {}

          if path and (vim.uv.fs_realpath(path) or path) == bufname then
            table.insert(diagnostics, {
              row = M.object_row(params.bufnr, vim.tbl_get(k8s, "GroupVersionKind", "Kind") or "", k8s.Name or ""),
              col = 1,
              message = report.Diagnostic.Message .. "\n" .. (report.Remediation or ""),
              code = report.Check,
              severity = vim.diagnostic.severity.WARN,
              source = "kube-linter",
            })
          end
        end

        return diagnostics
      end,
    }),
  }
end

--- Concurrent kubectl requests while syncing schemas
local SYNC_JOBS = 4

---@type string|false|nil
local current_context_cache = nil

--- The context in use: the :KubeContext pick, else kubectl's current context,
--- looked up once per session
---
---@return string|nil
function M.current_context()
  if M.context then
    return M.context
  end

  if current_context_cache == nil then
    local ok, result = pcall(function()
      return vim.system({ "kubectl", "config", "current-context" }, { text = true }):wait(3000)
    end)

    current_context_cache = ok and result.code == 0 and vim.trim(result.stdout) or false
  end

  return current_context_cache or nil
end

---@param args string[]
---@return string[]
local function with_context(args)
  if M.context then
    vim.list_extend(args, { "--context", M.context })
  end

  return args
end

---@param cmd string[]
---@param stdin string|nil
---@param callback fun(result: vim.SystemCompleted)
local function run(cmd, stdin, callback)
  local ok, err = pcall(vim.system, cmd, { stdin = stdin, text = true, timeout = 60000 }, vim.schedule_wrap(callback))

  if not ok then
    vim.schedule(function()
      callback({ code = -1, signal = 0, stdout = "", stderr = tostring(err) })
    end)
  end
end

---@param result vim.SystemCompleted
---@param title string
local function report(result, title)
  local output = vim.trim((result.stdout or "") .. "\n" .. (result.stderr or ""))

  if result.code ~= 0 and output:lower():match("forbidden") then
    output = output
      .. "\n\nServer dry runs need the same create/patch access as a real apply."
      .. " :KubeSyncSchemas validates against this cluster's schemas with read access only."
  end

  vim.notify(output ~= "" and output or "no output", result.code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR, {
    title = title,
  })
end

--- Re-pick the current buffer's schema, e.g. after a sync or context change
local function rematch()
  if package.loaded["schema-companion"] and vim.tbl_contains({ "yaml", "helm" }, vim.bo.filetype) then
    pcall(require("schema-companion").match)
  end
end

--- Validate the buffer against the cluster with `kubectl apply --dry-run=server`.
--- Plain manifests are sent from the buffer, unsaved edits included; helm templates
--- are rendered from their chart on disk first.
---
---@param bufnr? integer
function M.dry_run(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local title = "KubeDryRun: " .. (M.current_context() or "no context")
  local apply = with_context({ "kubectl", "apply", "--dry-run=server", "-f", "-" })

  if vim.bo[bufnr].filetype ~= "helm" then
    run(apply, table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n"), function(result)
      report(result, title)
    end)

    return
  end

  local root = chart_root(bufnr)

  if not root then
    vim.notify("no Chart.yaml above this template", vim.log.levels.ERROR, { title = title })
    return
  end

  if vim.bo[bufnr].modified then
    vim.notify("rendering the chart from disk; unsaved changes are not included", vim.log.levels.WARN, {
      title = title,
    })
  end

  run({ "helm", "template", root }, nil, function(rendered)
    if rendered.code ~= 0 then
      report(rendered, title .. " (helm template)")
      return
    end

    run(apply, rendered.stdout, function(result)
      report(result, title)
    end)
  end)
end

--- Fetch the cluster's OpenAPI v3 schemas, CRDs included, and store them as strict
--- per-kind JSON schemas that take precedence over the upstream ones for this
--- context. Needs only read access to /openapi.
function M.sync_schemas()
  local openapi = require("utils.kubernetes_openapi")
  local context = M.current_context()

  if not context then
    vim.notify("no kubectl context", vim.log.levels.ERROR, { title = "KubeSyncSchemas" })
    return
  end

  local title = "KubeSyncSchemas: " .. context
  local dir = openapi.schema_dir(context)
  local staging = dir .. ".sync"

  vim.fn.delete(staging, "rf")

  run(with_context({ "kubectl", "get", "--raw", "/openapi/v3" }), nil, function(index)
    local ok, decoded = pcall(vim.json.decode, index.stdout or "")

    if index.code ~= 0 or not ok or type(decoded) ~= "table" then
      report(index, title)
      return
    end

    local queue = {}

    for path, entry in pairs(decoded.paths or {}) do
      local group, version = openapi.parse_path(path)

      if group then
        table.insert(queue, {
          group = group,
          version = version,
          url = type(entry) == "table" and entry.serverRelativeURL or ("/openapi/v3/" .. path),
        })
      end
    end

    local total, kinds, active, failed = #queue, 0, 0, {}

    vim.notify(("fetching %d API groups"):format(total), vim.log.levels.INFO, { title = title })

    local function finish()
      if kinds == 0 then
        vim.fn.delete(staging, "rf")
        vim.notify("no schemas converted", vim.log.levels.ERROR, { title = title })
        return
      end

      vim.fn.delete(dir, "rf")
      vim.uv.fs_rename(staging, dir)

      local message = ("%d kinds from %d API groups"):format(kinds, total - #failed)

      if #failed > 0 then
        message = message .. "\nfailed: " .. table.concat(failed, ", ")
      end

      vim.notify(message, #failed > 0 and vim.log.levels.WARN or vim.log.levels.INFO, { title = title })
      rematch()
    end

    local function next_job()
      if #queue == 0 then
        if active == 0 then
          finish()
        end

        return
      end

      local job = table.remove(queue)

      active = active + 1

      run(with_context({ "kubectl", "get", "--raw", job.url }), nil, function(result)
        active = active - 1

        local decoded_ok, doc = pcall(vim.json.decode, result.stdout or "")

        if result.code == 0 and decoded_ok and type(doc) == "table" then
          for _, item in ipairs(openapi.convert(doc, job.group, job.version)) do
            local path = openapi.schema_path(staging, item.group, item.version, item.kind)

            vim.fn.mkdir(vim.fs.dirname(path), "p")
            vim.fn.writefile({ vim.json.encode(item.schema) }, path)
            kinds = kinds + 1
          end
        else
          table.insert(failed, job.group == "" and job.version or (job.group .. "/" .. job.version))
        end

        next_job()
      end)
    end

    if total == 0 then
      finish()
      return
    end

    for _ = 1, math.min(SYNC_JOBS, total) do
      next_job()
    end
  end)
end

--- Pick the context dry runs and synced schemas use, without touching kubeconfig
function M.select_context()
  run({ "kubectl", "config", "get-contexts", "-o", "name" }, nil, function(result)
    if result.code ~= 0 then
      report(result, "KubeContext")
      return
    end

    local contexts = vim.split(vim.trim(result.stdout), "\n")

    table.insert(contexts, 1, "(kubectl current context)")

    vim.ui.select(contexts, { prompt = "Kubernetes context" }, function(choice, idx)
      if choice then
        M.context = idx > 1 and choice or nil
        current_context_cache = nil
        vim.notify("Kubernetes context: " .. choice)
        rematch()
      end
    end)
  end)
end

--- Pick the Kubernetes version whose upstream schemas validate manifests that have
--- no synced schema, then rematch the buffer
function M.select_schema_version()
  local matcher = require("schema-companion.sources.matchers.kubernetes")

  vim.ui.input({
    prompt = "Kubernetes schema version (e.g. v1.31.0, master): ",
    default = matcher.get_version(),
  }, function(version)
    if version and version ~= "" then
      matcher.set_version(version)
      rematch()
    end
  end)
end

return M
