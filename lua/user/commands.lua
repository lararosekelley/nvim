-- squash everything beneath top commit, useful during rebasing
vim.api.nvim_create_autocmd({ "FileType" }, {
	pattern = { "gitrebase" },
	callback = function()
		vim.cmd([[
      nnoremap <buffer> <leader>s :2,$s/^pick/squash/<CR>
    ]])
	end,
})

-- highlight yanked text
vim.api.nvim_create_autocmd({ "TextYankPost" }, {
	callback = function()
		vim.highlight.on_yank({ higroup = "Visual", timeout = 500 })
	end,
})

-- close location list if parent window closes
vim.cmd("autocmd QuitPre * silent! lclose")

-- spellcheck
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = { "markdown", "plaintext" },
	callback = function()
		vim.opt_local.spell = true
		vim.opt_local.spelllang = "en_us"
	end,
})

-- json comments
vim.api.nvim_create_autocmd({ "FileType" }, {
	pattern = { "json" },
	command = [[ syntax match Comment +\/\/.\+$+ ]],
})

-- edit neovim config
vim.api.nvim_create_user_command("Config", ":e ~/.config/nvim/init.lua", { bang = true })

-- show diagnostics on cursor hold
vim.cmd([[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]])

vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
	callback = function()
		vim.diagnostic.open_float()
	end,
})

-- recognize more file types

-- json
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile", "BufFilePre" }, {
	pattern = {
		"*.{artilleryrc,babelrc,eslintrc,jsdocrc,nycrc,stylelintrc,markdownlintrc,parcelrc,tern-project,tern-config,home}",
	},
	command = [[ set filetype=json ]],
})

-- yaml
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile", "BufFilePre" }, {
	pattern = { "Procfile", ".prettierrc", ".commitlintrc" },
	command = [[ set filetype=yaml ]],
})

-- dosini
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile", "BufFilePre" }, {
	pattern = { ".flake8", ".conf" },
	command = [[ set filetype=dosini ]],
})

-- tmux
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile", "BufFilePre" }, {
	pattern = { ".tmux.conf" },
	command = [[ set filetype=tmux ]],
})

-- react
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile", "BufFilePre" }, {
	pattern = { ".tsx" },
	command = [[ set filetype=typescriptreact ]],
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile", "BufFilePre" }, {
	pattern = { ".jsx" },
	command = [[ set filetype=javascriptreact ]],
})

-- shell
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile", "BufFilePre" }, {
	pattern = { ".env.*" },
	command = [[ set filetype=sh ]],
})

-- systemd
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile", "BufFilePre" }, {
	pattern = { ".service" },
	command = [[ set filetype=systemd ]],
})
