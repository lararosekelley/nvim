local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
  return
end

local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
  return
end

require("user.plugins.lsp.install")
require("user.plugins.lsp.handlers").setup()

local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics

null_ls.setup {
  debug = false,
  sources = {
    formatting.prettier.with {
      extra_filetypes = { "toml" },
      extra_args = {},
    },
    formatting.black.with {
      extra_args = { "--fast" },
    },
    formatting.stylua,
    formatting.google_java_format,
    diagnostics.flake8,
  },
}
