--- Treesitter config
---
--- Author: @lararosekelley
--- Last Modified: August 27th, 2025

return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local configs = require("nvim-treesitter.config")

      configs.setup({
        auto_install = true,
        ensure_installed = "all",
        ignore_install = { "ipkg" }, -- error on install as of 2025-08-27
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter", "folke/which-key.nvim" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = {
          lookahead = true,
        },
      })

      local select = require("nvim-treesitter-textobjects.select").select_textobject

      -- Function text objects
      vim.keymap.set({ "x", "o" }, "af", function()
        select("@function.outer", "textobjects")
      end, { desc = "Select outer function" })
      vim.keymap.set({ "x", "o" }, "if", function()
        select("@function.inner", "textobjects")
      end, { desc = "Select inner function" })

      -- Class text objects
      vim.keymap.set({ "x", "o" }, "ac", function()
        select("@class.outer", "textobjects")
      end, { desc = "Select outer class" })
      vim.keymap.set({ "x", "o" }, "ic", function()
        select("@class.inner", "textobjects")
      end, { desc = "Select inner class" })

      -- Loop text objects
      vim.keymap.set({ "x", "o" }, "al", function()
        select("@loop.outer", "textobjects")
      end, { desc = "Select outer loop" })
      vim.keymap.set({ "x", "o" }, "il", function()
        select("@loop.inner", "textobjects")
      end, { desc = "Select inner loop" })

      -- Register with which-key for documentation
      local wk = require("which-key")
      wk.add({
        { "a", group = "around", mode = { "x", "o" } },
        { "af", desc = "around function", mode = { "x", "o" } },
        { "ac", desc = "around class", mode = { "x", "o" } },
        { "al", desc = "around loop", mode = { "x", "o" } },
        { "i", group = "inner", mode = { "x", "o" } },
        { "if", desc = "inner function", mode = { "x", "o" } },
        { "ic", desc = "inner class", mode = { "x", "o" } },
        { "il", desc = "inner loop", mode = { "x", "o" } },
      })
    end,
  },
  -- automatically close tags for html, jsx, etc.
  {
    "windwp/nvim-ts-autotag",
    event = "BufReadPost",
    opts = {},
  },
}
