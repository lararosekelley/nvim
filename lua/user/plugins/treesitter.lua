local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
	return
end

configs.setup({
	ensure_installed = "all",
	ignore_install = { "gleam" },
	highlight = {
		enable = true,
		disable = {},
	},
	autotag = {
		enable = true,
	},
	autopairs = {
		enable = true,
	},
	indent = {
		enable = true,
		disable = { "python" },
	},
})
