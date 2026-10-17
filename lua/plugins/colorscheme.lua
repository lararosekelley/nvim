--- Load themes for Neovim
---
--- Author: @lararosekelley
--- Last Modified: October 17th, 2026

return {
  -- callie, from greylocklabs/themes; follows 'background', with callie-light
  -- for the light variant
  {
    "greylocklabs/themes",
    name = "callie",
    priority = 1000,
    lazy = false,
    config = function()
      vim.cmd.colorscheme("callie")
    end,
  },
}
