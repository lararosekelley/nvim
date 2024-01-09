local map = require("utils").map

local dbee_status_ok, dbee = pcall(require, "dbee")
if not dbee_status_ok then
	return
end

local dbee_sources_status_ok, dbee_sources = pcall(require, "dbee.sources")
if not dbee_sources_status_ok then
	return
end

dbee.setup({
	lazy = true,
	sources = {
		dbee_sources.EnvSource:new("DBEE_CONNECTIONS"),
	},
})

map("n", "<leader>D", "<cmd>lua require'dbee'.toggle()<CR>")
