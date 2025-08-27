--- Integration of AI tools and plugins for enhanced coding assistance
---
--- Author: @lararosekelley
--- Last Modified: August 27th, 2025

return {
  -- aider
  {
    "GeorgesAlkhouri/nvim-aider",
    cmd = "Aider",
    event = "VeryLazy",
    dependencies = {
      "folke/snacks.nvim",
      "catppuccin/nvim",
    },
    opts = {
      -- ensure environment variables are set for API keys
      args = {
        "--no-auto-commits",
        "--model anthropic/claude-sonnet-4-20250514",
      },
      auto_reload = true,
    },
    keys = {
      { "<leader>At", "<cmd>Aider toggle<cr>", desc = "Toggle Aider" },
      { "<leader>As", "<cmd>Aider send<cr>", desc = "Send to Aider", mode = { "n", "v" } },
      { "<leader>Ac", "<cmd>Aider command<cr>", desc = "Aider Commands" },
      { "<leader>Ab", "<cmd>Aider buffer<cr>", desc = "Send Buffer" },
      { "<leader>A+", "<cmd>Aider add<cr>", desc = "Add File" },
      { "<leader>A-", "<cmd>Aider drop<cr>", desc = "Drop File" },
      { "<leader>Ar", "<cmd>Aider add readonly<cr>", desc = "Add Read-Only" },
      { "<leader>AR", "<cmd>Aider reset<cr>", desc = "Reset Session" },
    },
  },
  -- copilot
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    event = "BufReadPost",
    opts = {
      -- attach to buffer
      should_attach = function(bufnr)
        local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
        local disabled_filetypes = {} -- add disabled filetypes here

        if vim.tbl_contains(disabled_filetypes, filetype) then
          return false
        end

        return true
      end,
      -- handled by nvim-cmp / blink.cmp
      suggestion = {
        enabled = false,
      },
      -- handled by nvim-cmp / blink.cmp
      panel = {
        enabled = false,
      },
      filetypes = {
        markdown = true,
        help = true,
      },
    },
  },
}
