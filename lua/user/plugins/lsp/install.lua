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

	if server == "sumneko_lua" then
		local sumneko_opts = require("user.plugins.lsp.settings.sumneko_lua")
		opts = vim.tbl_deep_extend("force", sumneko_opts, opts)
	end

	if server == "tsserver" then
		local tsserver_opts = require("user.plugins.lsp.settings.tsserver")
		opts = vim.tbl_deep_extend("force", tsserver_opts, opts)
	end

	lspconfig[server].setup(opts)
end
