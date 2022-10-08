local status_ok, lualine = pcall(require, "lualine")
if not status_ok then
	return
end

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

local lsp = {
	lsp_name,
	icon = "",
	cond = conditions.has_lsp,
	color = {
		gui = "bold",
	},
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
	padding = 0,
}

lualine.setup({
	options = {
		globalstatus = true,
		icons_enabled = true,
		theme = "auto",
		disabled_filetypes = { "alpha", "dashboard" },
		always_divide_middle = true,
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch" },
		lualine_c = { filename, diagnostics },
		lualine_x = { diff, filesize, filetype, lsp },
		lualine_y = { location },
		lualine_z = { "progress" },
	},
})
