local status_ok, copilot = pcall(require, "copilot")
if not status_ok then
	return
end

copilot.setup({
	suggestion = {
		suggestion = {
			enabled = false,
		},
		panel = {
			enabled = false,
		},
	},
})
