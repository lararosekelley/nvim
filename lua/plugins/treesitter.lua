--- Treesitter config
---
--- Author: @lararosekelley
--- Last Modified: August 27th, 2025

local plugin_enabled = require("utils").plugin_enabled

local textobjects = {
  select = {
    enable = true,
    lookahead = true,
    keymaps = {
      ["af"] = "@function.outer",
      ["if"] = "@function.inner",
      ["ac"] = "@class.outer",
      ["ic"] = "@class.inner",
      ["al"] = "@loop.outer",
      ["il"] = "@loop.inner",
    },
  },
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    opts = {
      auto_install = true,
      ensure_installed = "all",
      highlight = { enable = true },
      indent = { enable = true },
      textobjects = textobjects,
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = "VeryLazy",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      -- If treesitter is already loaded, we need to run config again for textobjects
      if plugin_enabled("nvim-treesitter") then
        require("nvim-treesitter.configs").setup({ textobjects = textobjects })
      end
    end,
  },
  -- automatically close tags for html, jsx, etc.
  {
    "windwp/nvim-ts-autotag",
    event = "BufReadPost",
    opts = {},
  },
}
