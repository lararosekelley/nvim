local map = require("utils").map

local status_ok, aider = pcall(require, "aider")
if not status_ok then
	return
end

aider.setup({
	map(
		"n",
		"<leader>A",
		":AiderOpen --no-stream --no-gitignore --model ollama_chat/qwen2.5-coder:7b<CR>",
		{ noremap = true, silent = true }
	),
})
