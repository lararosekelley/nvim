local map = require("utils").map

local status_ok, project = pcall(require, "project_nvim")
if not status_ok then
	return
end

project.setup({
	-- order matters here
	detection_methods = { "pattern", "lsp" },
	-- package.json omitted to avoid defining a project in every Yarn workspace
	patterns = { ".git", ".hg", ".svn", ".bzr", "Makefile", ".wikiroot", "pyproject.toml" },
	-- set to true to print message on project detection
	silent_chdir = true,
	scope_chdir = "tab",
	show_hidden = true,
})

local tele_status_ok, telescope = pcall(require, "telescope")
if not tele_status_ok then
	return
end

telescope.load_extension("projects")

map("n", "<leader>fp", ":Telescope projects<CR>")
