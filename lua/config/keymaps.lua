--- Keymaps that don't depend on plugins
---
--- Author: @lararosekelley
--- Last Modified: August 27th, 2025

local map = require("utils").map

-- leader key
map("", ",", "<Nop>")
vim.g.mapleader = ","
vim.g.maplocalleader = "\\"

-- mode guide
--   insert = "i"
--   normal = "n"
--   visual = "v"
--   select = "s"
--   term = "t"
--   command = "c"
--   terminal = "t"
--   lang = "l"
--   operator pending = "o"
--   visual and select = "x"
------------------

-- normal mode
------------

-- show command line with space bar
map("n", "<Space>", function()
  vim.api.nvim_feedkeys(":", "n", false)
end, { nowait = true })

-- jump to next/prev diagnostic
map("n", "<C-d>", "<Cmd>lua vim.diagnostic.goto_next({ buffer = 0 })<CR>", { desc = "Go to next diagnostic" })
map("n", "<C-S-D>", "<Cmd>lua vim.diagnostic.goto_prev({ buffer = 0 })<CR>", { desc = "Go to prev diagnostic" })

-- re-orient splits
map("n", "<leader>Tk", "<C-w>t<C-w>K", { desc = "Make split horizontal" })
map("n", "<leader>Th", "<C-w>t<C-w>H", { desc = "Make split vertical" })

-- reload neovim config
map("n", "<leader>\\", ":so % | echo 'Reloaded Neovim configuration.'<CR>", { desc = "Reload config" })

-- use arrow keys to navigate jump list
map("n", "<Left>", "<C-o>") -- go back
map("n", "<Right>", "<C-i>") -- go forward

-- resizing with arrows
map("n", "<C-Up>", ":resize -2<CR>")
map("n", "<C-Down>", ":resize +2<CR>")
map("n", "<C-Left>", ":vertical resize -2<CR>")
map("n", "<C-Right>", ":vertical resize +2<CR>")

-- splits
map("n", "<leader>v", ":vnew<CR>", { desc = "New vertical split" })
map("n", "<leader>h", "<C-w>n", { desc = "New horizontal split" })

-- tab navigation
map("n", "<S-u>", "gT")
map("n", "<S-i>", "gt")

-- clear highlighting with enter
map("n", "<CR>", ":noh<CR><CR>")

-- search with tab
map("n", "<Tab>", function()
  vim.api.nvim_feedkeys("/", "n", false)
end, { nowait = true })

-- close tabs to the right
map("n", "<leader>X", ":.+1,$tabdo :q<CR>", { desc = "Close all tabs to the right" })

-- copy and paste
map("n", "<leader>a", "ggVG", { desc = "Select all" })
map("n", "<leader>y", 'gg"*yG``', { desc = "Copy all contents to clipboard" })

-- toggle fold
map("n", "<leader>,", "za", { desc = "Toggle fold" })

-- find and replace under cursor
map("n", "<leader>S", ":%s/\\<<C-r><C-w>\\>/", { desc = "Find and replace under cursor" })

-- visual mode
--------------

-- paste without yanking deleted text
map("v", "p", '"_dP', { desc = "Paste without yanking" })

-- indentation
map("v", "<Tab>", ">gv", { desc = "Indent right" })
map("v", "<S-Tab>", "<gv", { desc = "Indent left" })
