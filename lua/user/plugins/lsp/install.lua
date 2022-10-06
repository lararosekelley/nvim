local status_ok, lsp_installer = pcall(require, "nvim-lsp-installer")
if not status_ok then
  return
end

local servers = {
  "bashls",
  "clangd",
  "cssmodules_ls",
  "dockerls",
  "eslint",
  "gopls",
  "graphql",
  "html",
  "jdtls",
  "jsonls",
  "ltex",
  "marksman",
  "perlnavigator",
  "prismals",
  "pyright",
  "solargraph",
  "sqlls",
  "sumneko_lua",
  "stylelint_lsp",
  "svelte",
  "tailwindcss",
  "terraformls",
  "tsserver",
  "vimls",
  "vuels",
  "yamlls",
}

lsp_installer.setup({
  automatic_installation = true,
  ui = {
    icons = {
      server_installed = "✓",
      server_pending = "➜",
      server_uninstalled = "✗"
    }
  }
})

local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status_ok then
  return
end

local opts = {}

-- add language server-specific settings here
for _, server in pairs(servers) do
  opts = {
    on_attach = require("user.plugins.lsp.handlers").on_attach,
    capabilities = require("user.plugins.lsp.handlers").capabilities,
  }

  if server == "sumneko_lua" then
    local sumneko_opts = require "user.plugins.lsp.settings.sumneko_lua"
    opts = vim.tbl_deep_extend("force", sumneko_opts, opts)
  end

  if server == "pyright" then
    local pyright_opts = require "user.plugins.lsp.settings.pyright"
    opts = vim.tbl_deep_extend("force", pyright_opts, opts)
  end

  lspconfig[server].setup(opts)
end
