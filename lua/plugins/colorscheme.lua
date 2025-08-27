--- Load themes for Neovim
---
--- Author: @lararosekelley
--- Last Modified: August 22nd, 2025

return {
  -- catppuccin
  {
    "catppuccin/nvim",
    priority = 1000,
    lazy = false,
    name = "catppuccin",
    opts = {
      -- see bufferline.nvim config in ui.lua for its specific fix
      auto_integrations = true,
    },
    config = function()
      vim.cmd.colorscheme("catppuccin")
    end,
  },
}
