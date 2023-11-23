local map = require("utils").map

local status_ok, refactoring = pcall(require, "refactoring")
if not status_ok then
	return
end

refactoring.setup({})

-- use telescope for refactoring in visual mode
local telescope_status_ok, telescope = pcall(require, "telescope")
if not telescope_status_ok then
	return
end

telescope.load_extension("refactoring")

map("v", "<leader>rr", "<Esc><cmd>lua require('telescope').extensions.refactoring.refactors()<CR>")

-- renaming support
local renamer_status_ok, renamer = pcall(require, "renamer")
if not renamer_status_ok then
	return
end

renamer.setup({})

map("v", "<leader>rn", "<cmd>lua require('renamer').rename()<CR>")
