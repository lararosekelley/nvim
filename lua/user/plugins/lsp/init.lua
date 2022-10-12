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

local code_actions = null_ls.builtins.code_actions
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
	debug = true,
	sources = {
		-- code actions
		code_actions.eslint.with({
			prefer_local = "node_modules/.bin",
		}),
		-- diagnostics
		diagnostics.flake8.with({
			prefer_local = ".venv/bin",
		}),
		diagnostics.markdownlint.with({
			extra_filetypes = { "vimwiki" },
		}),
		diagnostics.shellcheck,
		diagnostics.sqlfluff.with({
			extra_args = { "--dialect", "postgres" }, -- prefer postgresql
		}),
		diagnostics.write_good.with({
			extra_filetypes = { "vimwiki" },
		}),
		-- formatting
		formatting.black.with({
			extra_args = { "--fast" },
			prefer_local = ".venv/bin",
		}),
		formatting.google_java_format,
		formatting.markdownlint.with({
			extra_filetypes = { "vimwiki" },
		}),
		formatting.prettierd.with({
			extra_filetypes = { "toml" }, -- vimwiki markdown syntax
			ignore_filetypes = { "markdown" },
		}),
		formatting.stylua,
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
