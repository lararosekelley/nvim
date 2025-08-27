--- Utility functions for Neovim configuration
---
--- Author: @lararosekelley
--- Last Modified: August 27th, 2025

local M = {}

M.cache = {}

M.spec = { "lsp", { ".git", "lua" }, "cwd" }

M.detectors = {}

-- Terminal Mappings
function M.term_nav(dir)
  return function(self)
    return self:is_floating() and "<c-" .. dir .. ">" or vim.schedule(function()
      vim.cmd.wincmd(dir)
    end)
  end
end

function M.detectors.cwd()
  return { vim.uv.cwd() }
end

function M.detectors.pattern(buf, patterns)
  patterns = type(patterns) == "string" and { patterns } or patterns
  local path = M.bufpath(buf) or vim.uv.cwd()

  local pattern = vim.fs.find(function(name)
    for _, p in ipairs(patterns) do
      if name == p then
        return true
      end
      if p:sub(1, 1) == "*" and name:find(vim.pesc(p:sub(2)) .. "$") then
        return true
      end
    end
    return false
  end, { path = path, upward = true })[1]

  return pattern and { vim.fs.dirname(pattern) } or {}
end

function M.detectors.lsp(buf)
  local bufpath = M.bufpath(buf)

  if not bufpath then
    return {}
  end

  local roots = {} ---@type string[]
  local clients = M.get_clients({ bufnr = buf })
  clients = vim.tbl_filter(function(client)
    return not vim.tbl_contains(vim.g.root_lsp_ignore or {}, client.name)
  end, clients)
  for _, client in pairs(clients) do
    local workspace = client.config.workspace_folders
    for _, ws in pairs(workspace or {}) do
      roots[#roots + 1] = vim.uri_to_fname(ws.uri)
    end
    if client.root_dir then
      roots[#roots + 1] = client.root_dir
    end
  end
  return vim.tbl_filter(function(path)
    path = M.norm(path)
    return path and bufpath:find(path, 1, true) == 1
  end, roots)
end

function M.bufpath(buf)
  return M.realpath(vim.api.nvim_buf_get_name(assert(buf)))
end

--- Prints a table
---
--- @param o table
--- @return string
function M.dump(o)
  if type(o) == "table" then
    local s = "{ "

    for k, v in pairs(o) do
      if type(k) ~= "number" then
        k = '"' .. k .. '"'
      end
      s = s .. "[" .. k .. "] = " .. M.dump(v) .. ","
    end

    return s .. "} "
  else
    return tostring(o)
  end
end

--- Normalizes a file path
---
--- @param path string
--- @return string
function M.norm(path)
  if path:sub(1, 1) == "~" then
    local home = vim.uv.os_homedir()
    if home:sub(-1) == "\\" or home:sub(-1) == "/" then
      home = home:sub(1, -2)
    end
    path = home .. path:sub(2)
  end

  path = path:gsub("\\", "/"):gsub("/+", "/")

  return path:sub(-1) == "/" and path:sub(1, -2) or path
end

function M.cwd()
  return M.realpath(vim.uv.cwd()) or ""
end

function M.realpath(path)
  if path == "" or path == nil then
    return nil
  end
  path = vim.uv.fs_realpath(path) or path
  return M.norm(path)
end

function M.get_clients(opts)
  local ret = {}
  if vim.lsp.get_clients then
    ret = vim.lsp.get_clients(opts)
  else
    ret = vim.lsp.get_active_clients(opts)
    if opts and opts.method then
      ret = vim.tbl_filter(function(client)
        return client.supports_method(opts.method, { bufnr = opts.bufnr })
      end, ret)
    end
  end
  return opts and opts.filter and vim.tbl_filter(opts.filter, ret) or ret
end

--- Finds the root directory of the current project
---
--- @param opts? table
--- @return table
function M.root_dir(opts)
  opts = vim.tbl_extend("force", {
    cwd = false,
    subdirectory = true,
    parent = true,
    other = true,
    icon = "󱉭 ",
  }, opts or {})

  local function get()
    local cwd = M.cwd()
    local root = M.get({ normalize = true })
    local name = vim.fs.basename(root)

    if root == cwd then
      -- root is cwd
      return opts.cwd and name
    elseif root:find(cwd, 1, true) == 1 then
      -- root is subdirectory of cwd
      return opts.subdirectory and name
    elseif cwd:find(root, 1, true) == 1 then
      -- root is parent directory of cwd
      return opts.parent and name
    else
      -- root and cwd are not related
      return opts.other and name
    end
  end

  return {
    function()
      return (opts.icon and opts.icon .. " ") .. get()
    end,
    cond = function()
      return type(get()) == "string"
    end,
    color = opts.color,
  }
end

--- Returns the root directory based on:
---   * lsp workspace folders
---   * lsp root_dir
---   * root pattern of filename of the current buffer
---   * root pattern of cwd
---
--- @param opts? table
--- @return string
function M.get(opts)
  opts = opts or {}

  local buf = opts.buf or vim.api.nvim_get_current_buf()
  local ret = M.cache[buf]

  if not ret then
    local roots = M.detect({ all = false, buf = buf })
    ret = roots[1] and roots[1].paths[1] or vim.uv.cwd()
    M.cache[buf] = ret
  end

  if opts and opts.normalize then
    return ret
  end

  return M.is_windows() and ret:gsub("/", "\\") or ret
end

--- TBD
---
--- @param spec string|string[]|fun(buf: number): (string|string[])
--- @return fun(buf: number): (string|string[])
function M.resolve(spec)
  if M.detectors[spec] then
    return M.detectors[spec]
  elseif type(spec) == "function" then
    return spec
  end

  return function(buf)
    return M.detectors.pattern(buf, spec)
  end
end

--- TBD
---
--- @param opts? { buf?: number, spec?: (string|string[]|fun(buf: number): (string|string[]))[], all?: boolean }
function M.detect(opts)
  opts = opts or {}
  opts.spec = opts.spec or M.spec
  opts.buf = (opts.buf == nil or opts.buf == 0) and vim.api.nvim_get_current_buf() or opts.buf

  local ret = {}
  for _, spec in ipairs(opts.spec) do
    local paths = M.resolve(spec)(opts.buf)
    paths = paths or {}
    paths = type(paths) == "table" and paths or { paths }
    local roots = {} ---@type string[]
    for _, p in ipairs(paths) do
      local pp = M.realpath(p)
      if pp and not vim.tbl_contains(roots, pp) then
        roots[#roots + 1] = pp
      end
    end
    table.sort(roots, function(a, b)
      return #a > #b
    end)
    if #roots > 0 then
      ret[#ret + 1] = { spec = spec, paths = roots }
      if opts.all == false then
        break
      end
    end
  end

  return ret
end

--- Set key mappings
---
--- @param mode string|string[]
--- @param lhs string
--- @param rhs string|function
--- @param opts? table
--- @return nil
function M.map(mode, lhs, rhs, opts)
  local keymap = vim.keymap.set
  local options = { silent = true, noremap = true } -- silent keymap option

  if opts then
    options = vim.tbl_extend("force", options, opts)
  end

  keymap(mode, lhs, rhs, options)
end

--- Checks if a file exists
---
--- @param name string
--- @return boolean
function M.file_exists(name)
  local f = io.open(name, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

local cache = {} ---@type table<(fun()), table<string, any>>

--- Memoizes a function to cache its results based on the arguments passed.
---
--- @generic T: fun()
--- @param fn T
--- @return T
function M.memoize(fn)
  return function(...)
    local key = vim.inspect({ ... })
    cache[fn] = cache[fn] or {}
    if cache[fn][key] == nil then
      cache[fn][key] = fn(...)
    end
    return cache[fn][key]
  end
end

--- Optimized treesitter foldexpr for Neovim >= 0.10.0, borrowed from LazyVim
---
--- @return string
function M.foldexpr()
  local buf = vim.api.nvim_get_current_buf()

  if vim.b[buf].ts_folds == nil then
    -- as long as we don't have a filetype, don't bother
    -- checking if treesitter is available (it won't)
    if vim.bo[buf].filetype == "" then
      return "0"
    end
    if vim.bo[buf].filetype:find("dashboard") then
      vim.b[buf].ts_folds = false
    else
      vim.b[buf].ts_folds = pcall(vim.treesitter.get_parser, buf)
    end
  end

  return vim.b[buf].ts_folds and vim.treesitter.foldexpr() or "0"
end

--- Check if a plugin is enabled (lazy.nvim)
---
--- @param name string
--- @return boolean
function M.plugin_enabled(name)
  local plugin = require("lazy.core.config").spec.plugins[name]

  return plugin ~= nil
end

--- Check if the current OS is Windows
---
--- @return boolean
function M.is_windows()
  return vim.uv.os_uname().sysname:find("Windows") ~= nil
end

return M
