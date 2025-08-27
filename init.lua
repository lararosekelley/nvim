--- Lara's Neovim configuration
---
--- Author: @lararosekelley
--- Last Modified: August 27th, 2025

-- ensure vim version is at least 0.9.0
if vim.fn.has("nvim-0.9.0") == 0 then
  vim.api.nvim_echo({
    { "This Neovim configuration requires a version >= 0.9.0\n", "ErrorMsg" },
    { "Press any key to exit...", "MoreMsg" },
  }, true, {})

  vim.fn.getchar()
  vim.cmd([[quit]])

  return {}
end

-- enable experimental lua module loader
vim.loader.enable()

-- settings
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- plugin manager (will automatically load plugins from `lua/plugins/*.lua`)
require("config.lazy")
