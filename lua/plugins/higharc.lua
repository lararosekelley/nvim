--- Higharc CLI integration for Neovim
---
--- Author: @lararosekelley

local icons = require("config.icons").icons.whichkey

return {
  -- Local higharc plugin
  {
    dir = vim.fn.stdpath("config") .. "/higharc",
    name = "higharc.nvim",
    event = "VeryLazy",
    config = function()
      require("higharc").setup({
        terminal = {
          win = {
            position = "bottom",
            height = 0.4,
          },
        },
      })
    end,
  },
  -- Which-key group registration
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>H", group = "Higharc", icon = { icon = icons.higharc, color = "yellow" } },
      },
    },
  },
  -- Keymaps via snacks (higharc uses snacks terminal/picker)
  {
    "folke/snacks.nvim",
    keys = {
      -- Command picker
      {
        "<leader>Hh",
        function()
          require("higharc.picker").pick()
        end,
        desc = "All Commands",
      },
      {
        "<leader>Hr",
        function()
          require("higharc.picker").rebuild_cache()
        end,
        desc = "Rebuild Command Cache",
      },
      -- Test commands
      {
        "<leader>Ht",
        function()
          require("higharc.test").run_current()
        end,
        desc = "Test Current File",
      },
      {
        "<leader>Hw",
        function()
          require("higharc.test").watch_current()
        end,
        desc = "Test Watch Current File",
      },
      {
        "<leader>HT",
        function()
          require("higharc.test").pick()
        end,
        desc = "Pick Test Command",
      },
      {
        "<leader>Ha",
        function()
          require("higharc.test").run_all()
        end,
        desc = "Test All",
      },
      {
        "<leader>Hd",
        function()
          require("higharc.picker").debug_cache()
        end,
        desc = "Debug Cache",
      },
    },
  },
}
