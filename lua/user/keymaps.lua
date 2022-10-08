local map = require("utils").map

-- comma as leader key
map("", ",", "<Nop>")
vim.g.mapleader = ","

-- mode guide
--   insert = "i"
--   normal = "n"
--   visual = "v"
--   visual = "x"
--   term = "t"
--   command = "c"

-- normal mode

-- initiate commands with space
map("n", "<Space>", ":")

-- re-orient splits
map("n", "<leader>tk", "<C-w>t<C-w>K") -- change vertical to horizontal
map("n", "<leader>th", "<C-w>t<C-w>H") -- change horizontal to vertical

-- reload neovim config
map("n", "<leader>r", ":so % | echo 'Reloaded Neovim configuration.'<CR>")

-- use arrow keys to navigate history
map("n", "<Left>", "<C-o>") -- go back
map("n", "<Right>", "<C-i>") -- go forward

-- resizing with arrows
map("n", "<C-Up>", ":resize -2<CR>")
map("n", "<C-Down>", ":resize +2<CR>")
map("n", "<C-Left>", ":vertical resize -2<CR>")
map("n", "<C-Right>", ":vertical resize +2<CR>")

-- splits
map("n", "<leader>v", ":vnew<CR>") -- new vertical split
map("n", "<leader>h", "<C-w>n") -- new horizontal split

-- tab navigation
map("n", "<S-h>", "gT")
map("n", "<S-l>", "gt")

-- clear highlighting with enter
map("n", "<CR>", ":noh<CR><CR>")

-- search with tab
map("n", "<Tab>", "/")

-- close all buffers
map("n", "<leader>x", ":bufdo bd<CR>")

-- close tabs to the right
map("n", "<leader>X", ":.+1,$tabdo :q<CR>")

-- copy and paste
map("n", "<leader>a", "ggVG") -- select all content in file
map("n", "<leader>y", 'gg"*yG``') -- copy file content to clipboard
map("n", "<leader>yg", ":.GBrowse!<CR>") -- copy link to line in git remote repository

-- remove trailing whitespace from file
map("n", "<leader>w", ":let _s=@/<Bar>:%s/\\s\\+$//e<Bar>:let @/=_s<Bar><CR>")

-- reformat file
map("n", "<leader>g", "ggVGgq")

-- toggle fold
map("n", "<leader>,", "za")

-- find and replace under cursor
map("n", "<leader>s", ":%s/\\<<C-r><C-w>\\>/")

-- visual mode

-- paste without yanking deleted text
map("v", "p", '"_dP')

-- indentation
map("v", "<Tab>", ">gv")
map("v", "<S-Tab>", "<gv")
