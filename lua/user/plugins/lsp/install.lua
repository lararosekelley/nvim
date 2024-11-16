local status_ok, mason = pcall(require, "mason")
if not status_ok then
	return
end

local mason_lspconfig_status_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if not mason_lspconfig_status_ok then
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
	"perlnavigator",
	"prismals",
	"pyright",
	"solargraph",
	"sqlls",
	"lua_ls",
	"stylelint_lsp",
	"svelte",
	"tailwindcss",
	"terraformls",
	"ts_ls",
	"vimls",
	"vuels",
	"yamlls",
}

mason.setup({
	ui = {
		check_outdated_packages_on_open = true,
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗",
		},
	},
})

mason_lspconfig.setup({
	automatic_installation = true,
	ensure_installed = servers,
})

local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status_ok then
	return
end

for _, server in pairs(servers) do
	-- settings for all language servers
	local opts = {
		on_attach = require("user.plugins.lsp.handlers").on_attach,
		capabilities = require("user.plugins.lsp.handlers").capabilities,
	}

	-- language-specific settings

	if server == "pyright" then
		local pyright_opts = require("user.plugins.lsp.settings.pyright")
		opts = vim.tbl_deep_extend("force", pyright_opts, opts)
	end

	if server == "lua_ls" then
		local lua_opts = require("user.plugins.lsp.settings.lua_ls")
		opts = vim.tbl_deep_extend("force", lua_opts, opts)
	end

	if server == "ts_ls" then
		local ts_ls_opts = require("user.plugins.lsp.settings.ts_ls")
		opts = vim.tbl_deep_extend("force", ts_ls_opts, opts)
	end

	lspconfig[server].setup(opts)
end
