--- Utility functions for Neovim configuration
---
--- Author: @lararosekelley
--- Last Modified: August 27th, 2025

local M = {}

---@type table<(fun()), table<string, any>>
M.cache = {}

function M.remove_at(t, index)
  local new = {}

  for i = 1, #t do
    if i ~= index then
      table.insert(new, t[i])
    end
  end

  return new
end

--- Navigate between terminal and normal windows
---
--- @param dir string
--- @return function
function M.term_nav(dir)
  return function(self)
    return self:is_floating() and "<c-" .. dir .. ">" or vim.schedule(function()
      vim.cmd.wincmd(dir)
    end)
  end
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

--- Memoizes a function to cache its results based on the arguments passed.
---
--- @generic T: fun()
--- @param fn T
--- @return T
function M.memoize(fn)
  return function(...)
    local key = vim.inspect({ ... })

    M.cache[fn] = M.cache[fn] or {}

    if M.cache[fn][key] == nil then
      M.cache[fn][key] = fn(...)
    end

    return M.cache[fn][key]
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

return M
