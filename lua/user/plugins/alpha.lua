local map = require("utils").map

local status_ok, alpha = pcall(require, "alpha")
if not status_ok then
	return
end

local dashboard = require("alpha.themes.dashboard")
dashboard.section.header.val = {
	[[                               __                ]],
	[[  ___     ___    ___   __  __ /\_\    ___ ___    ]],
	[[ / _ `\  / __`\ / __`\/\ \/\ \\/\ \  / __` __`\  ]],
	[[/\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \ ]],
	[[\ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\]],
	[[ \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/]],
}

dashboard.section.buttons.val = {
	dashboard.button("e", " " .. " New file", ":ene <BAR> startinsert<CR>"),
	dashboard.button("r", "󱋡 " .. " Recent files", ":Telescope oldfiles<CR>"),
	dashboard.button(
		"p",
		"󱃖 " .. " Recent projects",
		":lua require('telescope').extensions.projects.projects()<CR>"
	),

	dashboard.button("f", "󰱼 " .. " Find file in project", ":Telescope git_files<CR>"),
	dashboard.button("F", " " .. " Find file in folder", ":Telescope find_files<CR>"),
	dashboard.button("g", " " .. " Find file with grep", ":Telescope live_grep<CR>"),

	dashboard.button("c", " " .. " Edit config", ":e ~/.config/nvim/init.lua<CR>"),

	dashboard.button("t", " " .. " Open terminal", ":ToggleTerm<CR>"),

	dashboard.button("h", "󰗶 " .. "Run health checks", ":checkhealth<CR>"),

	dashboard.button("q", "󰩈 " .. " Quit", ":qa<CR>"),
}

local function footer()
	return "lararosekelley.com"
end

dashboard.section.footer.val = footer()
dashboard.section.footer.opts.hl = "Type"
dashboard.section.header.opts.hl = "Include"
dashboard.section.buttons.opts.hl = "Keyword"

dashboard.opts.opts.noautocmd = true
alpha.setup(dashboard.opts)

map("n", "<leader>H", ":Alpha<CR>")
