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

local augroup = vim.api.nvim_create_augroup("LspFormatOnSave", {})

-- only format with null-ls
local lsp_format = function(bufnr)
	vim.lsp.buf.format({
		filter = function(client)
			return client.name == "null-ls"
		end,
		bufnr = bufnr,
	})
end

null_ls.setup({
	debug = false,
	sources = {
		formatting.prettierd.with({
			extra_filetypes = { "toml" },
		}),
		formatting.black.with({
			extra_args = { "--fast" },
		}),
		formatting.stylua,
		formatting.google_java_format,
		diagnostics.flake8,
	},
	on_attach = function(client, bufnr)
		if client.supports_method("textDocument/formatting") then
			vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = augroup,
				buffer = bufnr,
				callback = function()
					lsp_format(bufnr)
				end,
			})
		end
	end,
})
