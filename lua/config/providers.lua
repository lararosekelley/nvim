local file_exists = require("utils").file_exists

-- disable perl
vim.g.loaded_perl_provider = 0

-- check for executables
local python2_executable = vim.fn.expand("~/.pyenv/versions/neovim2.7/bin/python")
local python3_executable = vim.fn.expand("~/.pyenv/versions/neovim3.13/bin/python")

if file_exists(python2_executable) then
	vim.g.python_host_prog = python2_executable
else
	print("Missing Python 2 executable!")
end

if file_exists(python3_executable) then
	vim.g.python3_host_prog = python3_executable
else
	print("Missing Python 3 executable!")
end
