-- higharc.nvim terminal integration (snacks.nvim)
local M = {}

local config = require("higharc.config")

---Run a higharc command in a snacks terminal
---@param cmd string|string[] The higharc subcommand(s) e.g. "test base" or {"test", "base", "mytest"}
---@param opts table|nil Additional options
function M.run(cmd, opts)
  opts = opts or {}

  local ok, snacks = pcall(require, "snacks")
  if not ok then
    vim.notify("snacks.nvim is required for higharc.nvim terminal", vim.log.levels.ERROR)
    return
  end

  local root = config.get_project_root()
  local higharc_cmd = config.get_cmd()

  -- Build command string
  local cmd_str
  if type(cmd) == "table" then
    cmd_str = higharc_cmd .. " " .. table.concat(cmd, " ")
  else
    cmd_str = higharc_cmd .. " " .. cmd
  end

  -- Merge terminal options
  local term_opts = vim.tbl_deep_extend("force", {
    cwd = root,
    interactive = false,
    auto_close = false,
  }, config.options.terminal, opts)

  snacks.terminal(cmd_str, term_opts)
end

---Run a raw command in a snacks terminal (for non-higharc commands)
---@param cmd string The full command to run
---@param opts table|nil Additional options
function M.run_raw(cmd, opts)
  opts = opts or {}

  local ok, snacks = pcall(require, "snacks")
  if not ok then
    vim.notify("snacks.nvim is required for higharc.nvim terminal", vim.log.levels.ERROR)
    return
  end

  local root = config.get_project_root()

  local term_opts = vim.tbl_deep_extend("force", {
    cwd = root,
    interactive = false,
    auto_close = false,
  }, config.options.terminal, opts)

  snacks.terminal(cmd, term_opts)
end

return M
