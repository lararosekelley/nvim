local map = require("utils").map

local status_ok, tmux = pcall(require, "nvim-tmux-navigation")
if not status_ok then
  return
end

map("n", "<C-h>", tmux.NvimTmuxNavigateLeft)
map("n", "<C-j>", tmux.NvimTmuxNavigateDown)
map("n", "<C-k>", tmux.NvimTmuxNavigateUp)
map("n", "<C-l>", tmux.NvimTmuxNavigateRight)
map("n", "<C-\\>", tmux.NvimTmuxNavigateLastActive)
map("n", "<C-Space>", tmux.NvimTmuxNavigateNext)
