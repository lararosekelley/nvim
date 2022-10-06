local map = require("utils").map

local status_ok, telescope = pcall(require, "telescope")
if not status_ok then
  return
end

local trouble_status_ok, trouble_telescope = pcall(require, "trouble.providers.telescope")
if not trouble_status_ok then
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
        ["<C-d>"] = trouble_telescope.open_with_trouble,
        ["<C-u"] = false,
      },
      n = {
        ["<C-d>"] = trouble_telescope.open_with_trouble,
      },
    },
  },
}

map("n", "<leader>fb", ":Telescope buffers<CR>") -- search open buffers
map("n", "<leader>fc", ":Telescope commands<CR>") -- search and run commands
map("n", "<leader>ff", ":Telescope git_files<CR>") -- search files in project
map("n", "<leader>fF", ":Telescope find_files<CR>") -- search files in folder 
map("n", "<leader>fg", ":Telescope live_grep<CR>") -- search for string
map("n", "<leader>fm", ":Telescope man_pages<CR>") -- search man pages
map("n", "<leader>fo", ":Telescope oldfiles<CR>") -- search previously open files
map("n", "<leader>fs", ":Telescope grep_string<CR>") -- search for string under cursor
