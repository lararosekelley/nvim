local status_ok, lualine = pcall(require, "lualine")
if not status_ok then
	return
end

local lazy_status_ok, lazy_status = pcall(require, "lazy.status")
if not lazy_status_ok then
	return
end

local theme = require("lualine.themes.everforest")

local no_lsp = "no lsp"

local lsp_name = function()
	local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
	local clients = vim.lsp.get_active_clients()

	if next(clients) == nil then
		return no_lsp
	end

	for _, client in ipairs(clients) do
		local filetypes = client.config.filetypes
		if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
			return client.name
		end
	end

	return no_lsp
end

local conditions = {
	buffer_not_empty = function()
		return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
	end,
	hide_in_width = function()
		return vim.fn.winwidth(0) > 120
	end,
	check_git_workspace = function()
		local filepath = vim.fn.expand("%:p:h")
		local gitdir = vim.fn.finddir(".git", filepath .. ";")
		return gitdir and #gitdir > 0 and #gitdir < #filepath
	end,
	has_lsp = function()
		return lsp_name() ~= no_lsp
	end,
}

local branch = {
	"branch",
	cond = conditions.check_git_workspace,
}

local diagnostics = {
	"diagnostics",
	sources = { "nvim_diagnostic" },
	sections = { "error", "warn", "info" },
	symbols = { error = " ", warn = " ", info = " " },
	always_visible = true,
}

local diff = {
	"diff",
	symbols = { added = " ", modified = " ", removed = " " },
	cond = conditions.check_git_workspace,
}

local filename = {
	"filename",
	file_stautus = false,
	newfile_status = false,
	path = 1,
	cond = conditions.hide_in_width,
}

local filesize = {
	"filesize",
	cond = conditions.buffer_not_empty,
}

local filetype = {
	"filetype",
	color = {
		gui = "bold",
	},
}

local location = {
	"location",
	padding = {
		left = 0,
		right = 1,
	},
}

local lsp = {
	lsp_name,
	icon = "",
	cond = conditions.has_lsp,
}

local updates = {
	lazy_status.updates,
	cond = lazy_status.has_updates,
}

-- everforest colors: https://user-images.githubusercontent.com/58662350/214382274-0108806d-b605-4047-af4b-c49ae06a2e8e.png
local gray = "#bg1"
local darkgray = "#bg0"

-- prevent mode from changing background color
theme.normal.c.fg = gray
theme.normal.c.bg = darkgray
theme.insert.c.fg = gray
theme.insert.c.bg = darkgray
theme.visual.c.fg = gray
theme.visual.c.bg = darkgray
theme.replace.c.fg = gray
theme.replace.c.bg = darkgray
theme.command.c.fg = gray
theme.command.c.bg = darkgray
theme.replace.c.fg = gray
theme.replace.c.bg = darkgray
theme.inactive.c.fg = gray
theme.inactive.c.bg = darkgray

lualine.setup({
	options = {
		globalstatus = true,
		icons_enabled = true,
		theme = theme,
		disabled_filetypes = { "alpha", "dashboard" },
		always_divide_middle = true,
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { branch },
		lualine_c = { filename, diagnostics },
		lualine_x = { "copilot", diff, filesize, filetype, lsp },
		lualine_y = { updates },
		lualine_z = { location },
	},
})
