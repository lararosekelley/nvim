--- Shared spec helpers.

local M = {}

--- Absolute path to the repository root.
---
--- Specs cannot use `vim.fn.stdpath("config")` for this. Locally the two happen
--- to be the same directory, but in CI the checkout lives somewhere else
--- entirely and stdpath would point at an empty (or absent) ~/.config/nvim.
---
--- @type string
M.root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")

--- Resolve a path relative to the repository root.
---
--- @param relative string
--- @return string
function M.path(relative)
  return M.root .. "/" .. relative
end

return M
