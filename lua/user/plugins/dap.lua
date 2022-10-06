local map = require("utils").map

local dap_status_ok, dap = pcall(require, "dap")
if not dap_status_ok then
  return
end

local dap_ui_status_ok, dapui = pcall(require, "dapui")
if not dap_ui_status_ok then
  return
end

local dap_install_status_ok, dap_install = pcall(require, "dap-install")
if not dap_install_status_ok then
  return
end

dap_install.setup({})
dap_install.config("python", {})

dapui.setup {
  layouts = {
    {
      elements = {
        'scopes',
        'breakpoints',
        'stacks',
        'watches',
      },
      size = 40,
      position = 'left',
    },
    {
      elements = {
        'repl',
        'console',
      },
      size = 10,
      position = 'bottom',
    },
  },
}

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end

dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end

dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

map("n", "<leader>db", "<cmd>lua require'dap'.toggle_breakpoint()<CR>")
map("n", "<leader>dc", "<cmd>lua require'dap'.continue()<CR>")
map("n", "<leader>di", "<cmd>lua require'dap'.step_into()<CR>")
map("n", "<leader>do", "<cmd>lua require'dap'.step_over()<CR>")
map("n", "<leader>dO", "<cmd>lua require'dap'.step_out()<CR>")
map("n", "<leader>dr", "<cmd>lua require'dap'.repl.toggle()<CR>")
map("n", "<leader>dl", "<cmd>lua require'dap'.run_last()<CR>")
map("n", "<leader>du", "<cmd>lua require'dapui'.toggle()<CR>")
map("n", "<leader>dt", "<cmd>lua require'dap'.terminate()<CR>")
