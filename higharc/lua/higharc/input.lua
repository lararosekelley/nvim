-- higharc.nvim floating input with cmp support
local M = {}

local config = require("higharc.config")

---Open a floating input for editing a higharc command
---@param default string Default command text
---@param callback fun(input: string|nil) Called with input or nil if cancelled
function M.open(default, callback)
  -- Try to use snacks input if available
  local ok, snacks = pcall(require, "snacks")
  if ok and snacks.input then
    snacks.input({
      prompt = config.get_cmd() .. " ",
      default = default or "",
      win = {
        relative = "cursor",
        row = 1,
        col = 0,
      },
    }, function(input)
      if input and input ~= "" then
        callback(input)
      else
        callback(nil)
      end
    end)
    return
  end

  -- Fallback to custom floating window
  local buf = vim.api.nvim_create_buf(false, true)

  vim.bo[buf].filetype = "higharc-input"
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { default or "" })

  local width = math.max(60, #(default or "") + 10)
  local height = 1

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "cursor",
    width = width,
    height = height,
    row = 1,
    col = 0,
    style = "minimal",
    border = "rounded",
    title = " " .. config.get_cmd() .. " ",
    title_pos = "center",
  })

  vim.wo[win].wrap = false
  vim.wo[win].cursorline = false

  local line = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or ""
  vim.api.nvim_win_set_cursor(win, { 1, #line })

  vim.cmd("startinsert!")

  local cmp_ok, cmp = pcall(require, "cmp")
  if cmp_ok then
    cmp.setup.buffer({
      sources = {
        { name = "higharc" },
      },
    })
  end

  local function close_and_run()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local input = vim.trim(table.concat(lines, " "))
    vim.api.nvim_win_close(win, true)
    if input ~= "" then
      callback(input)
    else
      callback(nil)
    end
  end

  local function close_and_cancel()
    vim.api.nvim_win_close(win, true)
    callback(nil)
  end

  vim.keymap.set({ "n", "i" }, "<CR>", close_and_run, { buffer = buf })
  vim.keymap.set({ "n", "i" }, "<C-c>", close_and_cancel, { buffer = buf })
  vim.keymap.set("n", "<Esc>", close_and_cancel, { buffer = buf })
  vim.keymap.set("n", "q", close_and_cancel, { buffer = buf })
end

return M
