--- File and text search
---
--- Author: @lararosekelley
--- Last Modified: August 4th, 2026

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
  -- full-text search across the recoll index (PDFs, office docs, mail, notes)
  {
    "lararosekelley/recoll.nvim",
    dependencies = { "ibhagwan/fzf-lua" },
    cmd = { "Recoll", "RecollDir", "RecollIndex", "RecollIndexStop" },
    opts = {},
    keys = {
      { "<leader>sr", "<cmd>Recoll<cr>", desc = "Recoll Search" },
      { "<leader>sR", "<cmd>RecollDir<cr>", desc = "Recoll Search (cwd)" },
      { "<leader>si", "<cmd>RecollIndex<cr>", desc = "Recoll Update Index" },
    },
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
