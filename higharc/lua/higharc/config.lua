-- higharc.nvim configuration
local M = {}

---@class HigharcConfig
---@field project_root string|nil Project root (auto-detected if nil)
---@field yarn_cmd string Yarn command to use
---@field terminal HigharcTerminalConfig Terminal options

---@class HigharcTerminalConfig
---@field win SnacksWinConfig Window configuration for snacks terminal

---@type HigharcConfig
M.defaults = {
  project_root = nil,
  -- Command to run higharc (auto-detected if nil)
  cmd = nil,
  terminal = {
    win = {
      position = "bottom",
      height = 0.4,
    },
  },
}

---Detect the best command to run higharc
---@return string
local function detect_cmd()
  -- Check if higharc is globally available
  if vim.fn.executable("higharc") == 1 then
    return "higharc"
  end
  -- Fall back to yarn
  return "yarn higharc"
end

---Get the higharc command
---@return string
function M.get_cmd()
  if M.options.cmd then
    return M.options.cmd
  end
  return detect_cmd()
end

---@type HigharcConfig
M.options = {}

---@param opts HigharcConfig|nil
function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
end

---Get project root, auto-detecting if not configured
---@return string
function M.get_project_root()
  if M.options.project_root then
    return M.options.project_root
  end

  -- Look for package.json with higharc script
  local cwd = vim.fn.getcwd()
  local root = vim.fs.root(cwd, { "package.json" })

  if root then
    local pkg_path = root .. "/package.json"
    local f = io.open(pkg_path, "r")
    if f then
      local content = f:read("*a")
      f:close()
      if content:match('"higharc"') then
        return root
      end
    end
  end

  return cwd
end

return M
