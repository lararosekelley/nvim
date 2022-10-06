local M = {}

-- set key mappings
function M.map(mode, lhs, rhs, opts)
  local keymap = vim.keymap.set
  local options = { silent = true, noremap = true } -- silent keymap option

  if opts then
    options = vim.tbl_extend("force", options, opts)
  end

  keymap(mode, lhs, rhs, options)
end

return M
