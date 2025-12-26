-- higharc.nvim test runner
local M = {}

local config = require("higharc.config")
local terminal = require("higharc.terminal")

---Extract test name from file path
---@param filepath string
---@return string|nil test_name
local function extract_test_name(filepath)
  -- Get filename without extension
  local filename = vim.fn.fnamemodify(filepath, ":t:r")

  -- Remove common test suffixes/prefixes
  local name = filename
    :gsub("%.test$", "")
    :gsub("%.spec$", "")
    :gsub("^test_", "")
    :gsub("_test$", "")
    :gsub("Test$", "")

  return name
end

---Check if file looks like a test file
---@param filepath string
---@return boolean
local function is_test_file(filepath)
  local patterns = {
    "%.test%.[jt]sx?$",
    "%.spec%.[jt]sx?$",
    "__tests__/",
    "/tests?/",
  }

  for _, pattern in ipairs(patterns) do
    if filepath:match(pattern) then
      return true
    end
  end

  return false
end

---Get the corresponding test file for a source file
---@param filepath string
---@return string|nil
local function find_test_file(filepath)
  local root = config.get_project_root()
  local relative = filepath:gsub("^" .. vim.pesc(root) .. "/", "")

  -- Common test file patterns to try
  local base = vim.fn.fnamemodify(relative, ":r") -- remove extension
  local ext = vim.fn.fnamemodify(relative, ":e")
  local dir = vim.fn.fnamemodify(relative, ":h")
  local name = vim.fn.fnamemodify(relative, ":t:r")

  local candidates = {
    -- Same directory with .test/.spec suffix
    dir .. "/" .. name .. ".test." .. ext,
    dir .. "/" .. name .. ".spec." .. ext,
    -- __tests__ directory
    dir .. "/__tests__/" .. name .. ".test." .. ext,
    dir .. "/__tests__/" .. name .. "." .. ext,
    -- tests directory at same level
    dir .. "/tests/" .. name .. ".test." .. ext,
  }

  for _, candidate in ipairs(candidates) do
    local full_path = root .. "/" .. candidate
    if vim.fn.filereadable(full_path) == 1 then
      return candidate
    end
  end

  return nil
end

---Run test for the current file
---@param opts table|nil Options
function M.run_current(opts)
  opts = opts or {}

  local filepath = vim.api.nvim_buf_get_name(0)
  if filepath == "" then
    vim.notify("No file in current buffer", vim.log.levels.WARN)
    return
  end

  local root = config.get_project_root()
  local test_pattern

  if is_test_file(filepath) then
    -- Current file is a test file, use relative path from repo root
    test_pattern = filepath:gsub("^" .. vim.pesc(root) .. "/", "")
  else
    -- Try to find corresponding test file
    local test_file = find_test_file(filepath)
    if test_file then
      -- find_test_file already returns relative path
      test_pattern = test_file
    else
      -- Fall back to source file name
      test_pattern = extract_test_name(filepath)
    end
  end

  if not test_pattern or test_pattern == "" then
    vim.notify("Could not determine test pattern", vim.log.levels.WARN)
    return
  end

  M.run(test_pattern, opts)
end

---Run a test by pattern
---@param pattern string Test file pattern
---@param opts table|nil Options
function M.run(pattern, opts)
  opts = opts or {}

  local cmd = { "test", "base", pattern }

  if opts.watch then
    cmd = { "test", "watch", pattern }
  end

  terminal.run(cmd)
end

---Run all tests
---@param opts table|nil Options
function M.run_all(opts)
  opts = opts or {}
  terminal.run("test all")
end

---Run tests in watch mode for current file
function M.watch_current()
  M.run_current({ watch = true })
end

---Pick a test to run using fuzzy finder
function M.pick()
  local picker = require("higharc.picker")
  picker.pick_group("test")
end

return M
