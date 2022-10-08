local M = {}

-- print a table
function M.dump(o)
	if type(o) == "table" then
		local s = "{ "

		for k, v in pairs(o) do
			if type(k) ~= "number" then
				k = '"' .. k .. '"'
			end
			s = s .. "[" .. k .. "] = " .. M.dump(v) .. ","
		end

		return s .. "} "
	else
		return tostring(o)
	end
end

-- set key mappings
function M.map(mode, lhs, rhs, opts)
	local keymap = vim.keymap.set
	local options = { silent = true, noremap = true } -- silent keymap option

	if opts then
		options = vim.tbl_extend("force", options, opts)
	end

	keymap(mode, lhs, rhs, options)
end

return M
