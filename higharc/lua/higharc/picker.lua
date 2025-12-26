-- higharc.nvim fuzzy command picker (snacks.nvim)
local M = {}

local config = require("higharc.config")
local terminal = require("higharc.terminal")

---Get cache file path for current project (stored in nvim data dir)
---@return string
local function get_cache_path()
  local cache_dir = vim.fn.stdpath("data") .. "/higharc"
  -- Create dir if needed
  vim.fn.mkdir(cache_dir, "p")
  -- Use hash of project root for unique cache per project
  local root = config.get_project_root()
  local hash = vim.fn.sha256(root):sub(1, 12)
  return cache_dir .. "/cache-" .. hash .. ".json"
end

---Load cache from file
---@return { commands: HigharcCommand[]|nil, subcommands: table<string, string[]>|nil }|nil
local function load_cache_file()
  local path = get_cache_path()
  local f = io.open(path, "r")
  if not f then
    return nil
  end
  local content = f:read("*a")
  f:close()
  local ok, data = pcall(vim.json.decode, content)
  if ok and data then
    return data
  end
  return nil
end

---Save cache to file
---@param commands HigharcCommand[]
---@param subcommands table<string, string[]>
local function save_cache_file(commands, subcommands)
  local path = get_cache_path()
  local data = { commands = commands, subcommands = subcommands }
  local ok, json = pcall(vim.json.encode, data)
  if not ok then
    vim.notify("Failed to encode cache JSON", vim.log.levels.DEBUG)
    return false
  end
  local f = io.open(path, "w")
  if f then
    f:write(json)
    f:close()
    return true
  end
  vim.notify("Failed to write cache file: " .. path, vim.log.levels.DEBUG)
  return false
end

---@class HigharcCommand
---@field path string[] Command path segments
---@field full string Full command string (e.g., "test base")

---Get completions from higharc CLI
---@param prefix string[] Command path prefix
---@param include_flags boolean|nil Include flags in results
---@return string[] completions
local function get_completions(prefix, include_flags)
  local root = config.get_project_root()
  local cmd = config.get_cmd()

  -- Build completion query
  local args = vim.split(cmd, "%s+")
  table.insert(args, "--get-yargs-completions")
  table.insert(args, "higharc")
  for _, p in ipairs(prefix) do
    table.insert(args, p)
  end
  table.insert(args, "") -- empty string for "what comes next"

  local result = vim.system(args, { cwd = root, text = true, timeout = 30000 }):wait()

  if result.code ~= 0 or not result.stdout then
    return {}
  end

  local completions = {}
  for line in result.stdout:gmatch("[^\r\n]+") do
    -- Filter out special entries, optionally include flags
    local is_flag = line:match("^%-")
    if line ~= "" and not line:match("^:") then
      if include_flags or not is_flag then
        table.insert(completions, line)
      end
    end
  end

  return completions
end

---Get top-level commands only (fast, single call)
---@return HigharcCommand[]
local function get_top_level_commands()
  local completions = get_completions({})
  local commands = {}

  for _, comp in ipairs(completions) do
    table.insert(commands, {
      path = { comp },
      full = comp,
    })
  end

  return commands
end

---@type HigharcCommand[]|nil
local cached_commands = nil

---@type table<string, string[]>
local subcommand_cache = {}

---Get all higharc commands (cached)
---@param force_refresh boolean|nil Force cache refresh
---@return HigharcCommand[]
function M.get_commands(force_refresh)
  if cached_commands and not force_refresh then
    return cached_commands
  end

  -- Try loading from file cache first
  if not force_refresh then
    local file_cache = load_cache_file()
    if file_cache and file_cache.commands and #file_cache.commands > 0 then
      cached_commands = file_cache.commands
      subcommand_cache = file_cache.subcommands or {}
      return cached_commands
    end
  end

  cached_commands = get_top_level_commands()
  save_cache_file(cached_commands, subcommand_cache)
  return cached_commands
end

---Clear the command cache
function M.clear_cache()
  cached_commands = nil
  subcommand_cache = {}
  -- Delete cache file
  os.remove(get_cache_path())
end

---Get subcommand cache (for cmp source)
---@return table<string, string[]>
function M.get_subcommand_cache()
  return subcommand_cache
end

---Debug: show cache status
function M.debug_cache()
  local cmd_count = cached_commands and #cached_commands or 0
  local sub_count = 0
  for _ in pairs(subcommand_cache) do
    sub_count = sub_count + 1
  end
  local lines = {
    "Commands cached: " .. cmd_count,
    "Subcommand entries: " .. sub_count,
    "",
    "Subcommand keys:",
  }
  for k, v in pairs(subcommand_cache) do
    table.insert(lines, string.format("  %s: %d items", k, #v))
  end
  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end

---Get completions async
---@param prefix string[] Command path prefix
---@param include_flags boolean|nil Include flags in results
---@param callback fun(completions: string[])
local function get_completions_async(prefix, include_flags, callback)
  local root = config.get_project_root()
  local cmd = config.get_cmd()

  local args = vim.split(cmd, "%s+")
  table.insert(args, "--get-yargs-completions")
  table.insert(args, "higharc")
  for _, p in ipairs(prefix) do
    table.insert(args, p)
  end
  table.insert(args, "")

  local cmd_str = table.concat(args, " ")
  vim.system(args, { cwd = root, text = true, timeout = 30000 }, function(result)
    vim.schedule(function()
      if result.code ~= 0 or not result.stdout then
        vim.notify(string.format("CLI failed:\n  cmd: %s\n  cwd: %s\n  code: %s\n  stderr: %s",
          cmd_str, root, result.code, result.stderr or "nil"), vim.log.levels.WARN)
        callback({})
        return
      end

      local completions = {}
      for line in result.stdout:gmatch("[^\r\n]+") do
        local is_flag = line:match("^%-")
        if line ~= "" and not line:match("^:") then
          if include_flags or not is_flag then
            table.insert(completions, line)
          end
        end
      end
      callback(completions)
    end)
  end)
end

---Fully rebuild cache with all subcommands (async, non-blocking)
---@param callback function|nil Called when done
function M.rebuild_cache(callback)
  if not M.is_higharc_project() then
    vim.notify("Not in a higharc project", vim.log.levels.WARN)
    return
  end

  -- Clear existing cache
  M.clear_cache()

  -- Show loading notification
  vim.notify("Discovering higharc commands...", vim.log.levels.INFO)

  -- Get top-level commands async (no flags for top level)
  get_completions_async({}, false, function(completions)
    vim.notify(string.format("Got %d top-level completions", #completions), vim.log.levels.INFO)
    if #completions == 0 then
      -- Try sync as fallback to see error
      local sync_result = get_completions({}, false)
      vim.notify(string.format("Sync fallback got %d", #sync_result), vim.log.levels.INFO)
      if callback then callback() end
      return
    end

    -- Build command list
    cached_commands = {}
    for _, comp in ipairs(completions) do
      table.insert(cached_commands, { path = { comp }, full = comp })
    end

    local total = #cached_commands
    local completed = 0

    vim.notify(string.format("Caching %d commands...", total), vim.log.levels.INFO)

    -- Fetch subcommands for each (async, include flags)
    for _, cmd in ipairs(cached_commands) do
      get_completions_async(cmd.path, true, function(subs)
        subcommand_cache[cmd.full] = subs
        completed = completed + 1

        if completed == total then
          -- All done - save and notify
          save_cache_file(cached_commands, subcommand_cache)
          vim.notify(string.format("Cached %d commands", total), vim.log.levels.INFO)
          if callback then callback() end
        end
      end)
    end
  end)
end

---Check if we're in a higharc project
---@return boolean
function M.is_higharc_project()
  local root = config.get_project_root()
  local pkg_path = root .. "/package.json"
  local f = io.open(pkg_path, "r")
  if f then
    local content = f:read("*a")
    f:close()
    return content:match('"higharc"') ~= nil
  end
  return false
end

---Open the fuzzy command picker
---@param opts table|nil Picker options
function M.pick(opts)
  opts = opts or {}

  local ok, snacks = pcall(require, "snacks")
  if not ok then
    vim.notify("snacks.nvim is required for higharc.nvim picker", vim.log.levels.ERROR)
    return
  end

  if not M.is_higharc_project() then
    vim.notify("Not in a higharc project (no package.json with higharc found)", vim.log.levels.WARN)
    return
  end

  local commands = M.get_commands(opts.refresh)

  if #commands == 0 then
    vim.notify("No higharc commands found. Is the CLI installed?", vim.log.levels.WARN)
    return
  end

  -- Build picker items
  local items = {}
  for _, cmd in ipairs(commands) do
    table.insert(items, {
      text = cmd.full,
      cmd = cmd,
    })
  end

  snacks.picker.pick({
    title = "Higharc Commands",
    items = items,
    format = "text",
    preview = function(ctx)
      local item = ctx.item
      if not item or not item.cmd then
        return
      end
      -- Get completions for preview (cached)
      local cache_key = item.cmd.full
      local subs = subcommand_cache[cache_key]
      if not subs then
        -- Include flags for display
        subs = get_completions(item.cmd.path, true)
        subcommand_cache[cache_key] = subs
        -- Persist to file
        save_cache_file(cached_commands or {}, subcommand_cache)
      end
      local lines = {}
      local cmds = {}
      local flags = {}
      for _, sub in ipairs(subs) do
        if sub:match("^%-") then
          table.insert(flags, sub)
        else
          table.insert(cmds, sub)
        end
      end
      if #cmds > 0 then
        table.insert(lines, "Subcommands:")
        for _, cmd in ipairs(cmds) do
          table.insert(lines, "  " .. cmd)
        end
        table.insert(lines, "")
      end
      if #flags > 0 then
        table.insert(lines, "Flags:")
        for _, flag in ipairs(flags) do
          table.insert(lines, "  " .. flag)
        end
      end
      if #lines == 0 then
        table.insert(lines, "(no completions)")
      end
      ctx.preview:set_lines(lines)
    end,
    confirm = function(picker, item)
      picker:close()
      if item and item.cmd then
        M.pick_subcommand(item.cmd)
      end
    end,
  })
end

---Pick subcommand or run command
---@param cmd HigharcCommand The parent command
---@param selected_flags table|nil Already selected flags
---@param parent HigharcCommand|nil Parent command for back navigation
function M.pick_subcommand(cmd, selected_flags, parent)
  local snacks = require("snacks")
  selected_flags = selected_flags or {}

  -- Get cached completions for this command, fetch if not cached
  local comps = subcommand_cache[cmd.full]
  if not comps then
    vim.notify("Fetching completions for " .. cmd.full .. "...", vim.log.levels.INFO)
    comps = get_completions(cmd.path, true)
    subcommand_cache[cmd.full] = comps
    -- Persist to cache file
    save_cache_file(cached_commands or {}, subcommand_cache)
  end

  -- Separate subcommands and flags
  local subcmds = {}
  local flags = {}
  for _, c in ipairs(comps) do
    if c:match("^%-") then
      table.insert(flags, c)
    else
      table.insert(subcmds, c)
    end
  end

  -- Build the run command with selected flags
  local function get_run_cmd()
    if #selected_flags > 0 then
      return cmd.full .. " " .. table.concat(selected_flags, " ")
    end
    return cmd.full
  end

  -- Build items
  local items = {}

  -- Option to run the command (first, so it's pre-selected)
  local run_text = "▶ Run: " .. get_run_cmd()
  table.insert(items, {
    text = run_text,
    action = "run",
    cmd = cmd,
  })

  -- Option to edit command before running
  table.insert(items, {
    text = "✎ Edit & Run...",
    action = "edit",
    cmd = cmd,
  })

  -- Subcommands (can drill down further)
  for _, sub in ipairs(subcmds) do
    local new_path = vim.deepcopy(cmd.path)
    table.insert(new_path, sub)
    table.insert(items, {
      text = "→ " .. sub,
      action = "drill",
      cmd = { path = new_path, full = cmd.full .. " " .. sub },
    })
  end

  -- Flags (toggleable)
  for _, flag in ipairs(flags) do
    local is_selected = vim.tbl_contains(selected_flags, flag)
    local checkbox = is_selected and "☑" or "☐"
    table.insert(items, {
      text = checkbox .. " " .. flag,
      action = "toggle_flag",
      flag = flag,
      selected = is_selected,
    })
  end

  -- Back option at the bottom
  if parent then
    table.insert(items, {
      text = "← Back",
      action = "back",
      parent = parent,
    })
  else
    table.insert(items, {
      text = "← Back to commands",
      action = "back_to_root",
    })
  end

  if #items == 1 then
    -- Only "run" option, just run it
    terminal.run(get_run_cmd())
    return
  end

  snacks.picker.pick({
    title = config.get_cmd() .. " " .. cmd.full,
    items = items,
    format = "text",
    confirm = function(picker, item)
      picker:close()
      if not item then return end

      if item.action == "back" then
        -- Go back to parent
        M.pick_subcommand(item.parent, selected_flags)
      elseif item.action == "back_to_root" then
        -- Go back to main command picker
        M.pick()
      elseif item.action == "run" then
        terminal.run(get_run_cmd())
      elseif item.action == "edit" then
        -- Use cmdline with completion
        local current = get_run_cmd()
        vim.api.nvim_feedkeys(":Higharc " .. current, "n", false)
      elseif item.action == "drill" then
        -- Drill down into subcommand (carry flags, pass current as parent)
        M.pick_subcommand(item.cmd, selected_flags, cmd)
      elseif item.action == "toggle_flag" then
        -- Toggle flag and reopen picker (preserve parent for back nav)
        local new_flags = vim.deepcopy(selected_flags)
        if item.selected then
          -- Remove flag
          new_flags = vim.tbl_filter(function(f) return f ~= item.flag end, new_flags)
        else
          -- Add flag
          table.insert(new_flags, item.flag)
        end
        M.pick_subcommand(cmd, new_flags, parent)
      end
    end,
  })
end

---Pick a command within a specific group
---@param group string Command group (e.g., "test", "db")
---@param opts table|nil Picker options
function M.pick_group(group, opts)
  opts = opts or {}

  local ok, snacks = pcall(require, "snacks")
  if not ok then
    vim.notify("snacks.nvim is required for higharc.nvim picker", vim.log.levels.ERROR)
    return
  end

  if not M.is_higharc_project() then
    vim.notify("Not in a higharc project (no package.json with higharc found)", vim.log.levels.WARN)
    return
  end

  -- Get subcommands for this group from cache or fetch
  local comps = subcommand_cache[group] or get_completions({ group }, true)

  -- Separate subcommands and flags
  local subcmds = {}
  local flags = {}
  for _, c in ipairs(comps) do
    if c:match("^%-") then
      table.insert(flags, c)
    else
      table.insert(subcmds, c)
    end
  end

  local items = {}

  -- Option to run the group command as-is
  table.insert(items, {
    text = "▶ Run: " .. group,
    action = "run",
    cmd = { path = { group }, full = group },
  })

  -- Subcommands
  for _, sub in ipairs(subcmds) do
    table.insert(items, {
      text = "→ " .. sub,
      action = "drill",
      cmd = { path = { group, sub }, full = group .. " " .. sub },
    })
  end

  -- Flags
  for _, flag in ipairs(flags) do
    table.insert(items, {
      text = "  " .. flag,
      action = "flag",
      cmd = { path = { group }, full = group },
      flag = flag,
    })
  end

  snacks.picker.pick({
    title = "Higharc " .. group,
    items = items,
    format = "text",
    confirm = function(picker, item)
      picker:close()
      if not item then return end

      if item.action == "run" then
        terminal.run(item.cmd.full)
      elseif item.action == "drill" then
        M.pick_subcommand(item.cmd)
      elseif item.action == "flag" then
        terminal.run(item.cmd.full .. " " .. item.flag)
      end
    end,
  })
end

return M
