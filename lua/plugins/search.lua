--- File and text search
---
--- Author: @lararosekelley
--- Last Modified: August 27th, 2025

return {
  -- fuzzy finder
  {
    "ibhagwan/fzf-lua",
    event = "VeryLazy",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      {
        "JasinskiRafal/viu.nvim",
        dependencies = {
          "nvim-lua/plenary.nvim",
          "m00qek/baleia.nvim",
        },
        opts = {},
      },
    },
    opts = {},
  },
  -- better f and t motions
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash",
      },
      {
        "S",
        mode = { "n", "o", "x" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Remote Flash",
      },
      {
        "R",
        mode = { "o", "x" },
        function()
          require("flash").treesitter_search()
        end,
        desc = "Treesitter Search",
      },
      {
        "<c-s>",
        mode = { "c" },
        function()
          require("flash").toggle()
        end,
        desc = "Toggle Flash Search",
      },
    },
  },
}
