--- LSP configuration
---
--- Author: @lararosekelley
--- Last Modified: September 1st, 2025

local icons = require("config.icons").icons
local lsp_format = require("utils.lsp").lsp_format
local lsp_augroup = require("utils.lsp").lsp_augroup
local lsp_servers = require("utils.lsp").lsp_servers

return {
  -- lsp and diagnostics
  {
    "nvimtools/none-ls.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvimtools/none-ls-extras.nvim",
      "neovim/nvim-lspconfig",
      "RRethy/vim-illuminate", -- highlight other uses of word under cursor
    },
    config = function()
      local nls = require("null-ls")
      local handlers = require("plugins.lsp.handlers")
      local eslint_code_actions = require("none-ls.code_actions.eslint")
      local flake8_diagnostics = require("none-ls.diagnostics.flake8")

      local formatting = nls.builtins.formatting
      local diagnostics = nls.builtins.diagnostics

      handlers.setup()

      nls.setup({
        -- flip to true to debug
        debug = false,
        sources = {
          -- code actions
          eslint_code_actions.with({
            prefer_local = "node_modules/.bin",
          }),
          -- diagnostics
          flake8_diagnostics.with({
            prefer_local = ".venv/bin",
          }),
          diagnostics.markdownlint_cli2.with({
            extra_filetypes = { "vimwiki" },
          }),
          diagnostics.sqlfluff.with({
            extra_args = { "--dialect", "postgres" }, -- prefer postgresql
          }),
          -- formatting
          formatting.black.with({
            extra_args = { "--fast" },
            prefer_local = ".venv/bin",
          }),
          formatting.google_java_format,
          formatting.prettierd.with({
            extra_filetypes = { "toml", "vimwiki" },
          }),
          formatting.stylua,
        },
        on_attach = function(client, bufnr)
          -- https://github.com/nvimtools/none-ls.nvim/wiki/Avoiding-LSP-formatting-conflicts
          if client.supports_method("textDocument/formatting") then
            vim.api.nvim_clear_autocmds({ group = lsp_augroup, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePre", {
              group = lsp_augroup,
              buffer = bufnr,
              callback = lsp_format,
            })
          end
        end,
      })
    end,
  },
  -- non-LSP tool installer
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    event = "VeryLazy",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = {
        "black",
        "flake8",
        "google-java-format",
        "markdownlint-cli2",
        "prettierd",
        "rust-analyzer",
        "sqlfluff",
        "stylua",
      },
    },
  },
  -- language server installer
  {
    "mason-org/mason-lspconfig.nvim",
    event = "VeryLazy",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    keys = {
      { "<leader>M", "<cmd>Mason<cr>", desc = "Mason" },
    },
    config = function()
      local mason = require("mason")
      local mason_lspconfig = require("mason-lspconfig")
      local handlers = require("plugins.lsp.handlers")

      mason.setup({
        ui = {
          check_outdated_packages_on_open = true,
          icons = icons.mason,
        },
      })

      mason_lspconfig.setup({
        automatic_installation = true,
        ensure_installed = lsp_servers,
      })

      for _, server in pairs(lsp_servers) do
        -- settings for all language servers
        local opts = {
          on_attach = handlers.on_attach,
          capabilities = handlers.capabilities,
        }

        local server_exists, server_opts = pcall(require, "plugins.lsp.settings." .. server)
        if not server_exists then
          server_opts = {}
        end

        opts = vim.tbl_deep_extend("force", server_opts, opts)

        vim.lsp.config(server, opts)
        vim.lsp.enable(server)
      end
    end,
  },
  -- better lua lsp performance
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
}
