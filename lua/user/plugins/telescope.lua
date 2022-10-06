local map = require("utils").map

local status_ok, telescope = pcall(require, "telescope")
if not status_ok then
  return
end

local actions = require("telescope.actions")

telescope.setup {
  defaults = {
    path_display = { "smart" },
    file_ignore_patterns = { ".git", "node_modules" },
    mappings = {
      i = {
        ["<Down>"] = actions.cycle_history_next,
        ["<Up>"] = actions.cycle_history_prev,
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
      },
    },
  },
}

map("n", "<leader>fb", ":Telescope buffers<CR>") -- search open buffers
map("n", "<leader>fc", ":Telescope commands<CR>") -- search and run commands
map("n", "<leader>ff", ":Telescope find_files<CR>") -- search files in project
map("n", "<leader>fg", ":Telescope live_grep<CR>") -- search for string
map("n", "<leader>fm", ":Telescope man_pages<CR>") -- search man pages
map("n", "<leader>fo", ":Telescope oldfiles<CR>") -- search previously open files
map("n", "<leader>fs", ":Telescope grep_string<CR>") -- search for string under cursor
