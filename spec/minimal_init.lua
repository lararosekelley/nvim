--- Minimal Neovim configuration for the test harness.
--- Puts this config's lua/ directory and the cloned test dependencies on the
--- runtimepath, without loading init.lua or any plugin.

local this_file = debug.getinfo(1, "S").source:sub(2)
local root = vim.fn.fnamemodify(this_file, ":p:h:h")

vim.opt.runtimepath:prepend(root)

-- Plenary's runner rewrites runtimepath, so the test dependencies also go on
-- package.path. Lua's own searcher then resolves them whatever rtp ends up as.
for _, dir in ipairs(vim.fn.glob(root .. "/.tests/site/pack/deps/start/*", true, true)) do
  vim.opt.runtimepath:append(dir)
  package.path = dir .. "/lua/?.lua;" .. dir .. "/lua/?/init.lua;" .. package.path
end

-- The config's own modules, plus spec/ for the shared helpers, for the same reason.
package.path = root .. "/lua/?.lua;" .. root .. "/lua/?/init.lua;" .. root .. "/?.lua;" .. package.path

vim.opt.swapfile = false
vim.opt.shadafile = "NONE"

-- The harness runs with --noplugin for isolation, so plenary's commands have to
-- be sourced explicitly.
vim.cmd("runtime plugin/plenary.vim")
