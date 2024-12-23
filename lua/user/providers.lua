local function file_exists(name)
	local f = io.open(name, "r")
	if f ~= nil then
		io.close(f)
		return true
	else
		return false
	end
end

-- disable perl
vim.g.loaded_perl_provider = 0

-- check for executables
local python3_executable = vim.fn.expand("~/.pyenv/versions/neovim3.13/bin/python")

if file_exists(python3_executable) then
	vim.g.python3_host_prog = python3_executable
else
	print("Missing Python 3 executable - expected virtualenv in ~/.pyenv/versions/neovim3.13/")
end
