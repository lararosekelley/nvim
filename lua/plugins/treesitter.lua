--- Treesitter config
---
--- Author: @lararosekelley
--- Last Modified: August 25th, 2026

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false, -- main branch does not support lazy-loading
    build = ":TSUpdate",
    init = function()
      -- override the stalled upstream prisma grammar with our patched copy.
      -- must be registered before install/update runs. see vendor/tree-sitter-prisma/README.md
      vim.api.nvim_create_autocmd("User", {
        pattern = "TSUpdate",
        callback = function()
          require("nvim-treesitter.parsers").prisma = {
            tier = 2, -- unstable, as upstream has it, so install it by name below
            install_info = {
              path = vim.fn.stdpath("config") .. "/vendor/tree-sitter-prisma",
            },
          }
        end,
      })
    end,
    config = function()
      require("nvim-treesitter").setup()
      -- prisma is tier 2, so it is not covered by "stable" and needs naming
      require("nvim-treesitter").install({ "stable", "prisma" })

      -- main branch enables nothing by itself, so start highlighting and
      -- indenting per buffer. folds stay with utils.foldexpr.
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("ts_activate", { clear = true }),
        callback = function(args)
          local buf = args.buf
          local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)

          if not (lang and pcall(vim.treesitter.start, buf, lang)) then
            return
          end

          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
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

      local select_textobject = require("nvim-treesitter-textobjects.select").select_textobject

      -- Function text objects
      vim.keymap.set({ "x", "o" }, "af", function()
        select_textobject("@function.outer", "textobjects")
      end, { desc = "Select outer function" })
      vim.keymap.set({ "x", "o" }, "if", function()
        select_textobject("@function.inner", "textobjects")
      end, { desc = "Select inner function" })

      -- Class text objects
      vim.keymap.set({ "x", "o" }, "ac", function()
        select_textobject("@class.outer", "textobjects")
      end, { desc = "Select outer class" })
      vim.keymap.set({ "x", "o" }, "ic", function()
        select_textobject("@class.inner", "textobjects")
      end, { desc = "Select inner class" })

      -- Loop text objects
      vim.keymap.set({ "x", "o" }, "al", function()
        select_textobject("@loop.outer", "textobjects")
      end, { desc = "Select outer loop" })
      vim.keymap.set({ "x", "o" }, "il", function()
        select_textobject("@loop.inner", "textobjects")
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
