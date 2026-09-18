local M = {}

function M.enabled()
  return not vim.env.TMUX
    and vim.env.KITTY_WINDOW_ID ~= nil
    and vim.env.KITTY_WINDOW_ID ~= ""
    and vim.env.KITTY_LISTEN_ON ~= nil
    and vim.env.KITTY_LISTEN_ON ~= ""
    and vim.fn.executable("kitty") == 1
end

-- Keep the workaround in our config: lazy.nvim replaces the plugin checkout on updates.
function M.attach(kitty)
  local socket, failures, retry_at, warned = nil, 0, 0, false

  local function reset()
    socket, failures, retry_at = vim.env.KITTY_LISTEN_ON, 0, 0
  end

  local function available()
    if socket ~= vim.env.KITTY_LISTEN_ON then
      reset()
    end
    return kitty.config.enabled ~= false and M.enabled() and vim.uv.hrtime() / 1e6 >= retry_at
  end

  kitty.is_available = available
  kitty.build_kitty_command = function(_, command, args)
    local argv = { "kitty", "@", "--to", vim.env.KITTY_LISTEN_ON or "", command }
    vim.list_extend(argv, args or {})
    return argv
  end

  kitty.execute_kitty_command = function(_, argv)
    -- Upstream's interactive commands assume strings, and update() JSON-decodes ls even on failure.
    local empty = argv[5] == "ls" and "[]" or ""
    if not available() then
      return empty
    end

    local ok, result = pcall(function()
      return vim.system(argv, { text = true, timeout = 250 }):wait()
    end)
    local valid = ok and result.code == 0
    if valid and argv[5] == "ls" then
      local decoded, data = pcall(vim.json.decode, result.stdout or "")
      valid = decoded and type(data) == "table" and vim.islist(data)
    end

    if not valid then
      failures = math.min(failures + 1, 5)
      retry_at = vim.uv.hrtime() / 1e6 + math.min(5000 * 2 ^ (failures - 1), 60000)
      if not warned then
        warned = true
        local failed_socket = socket
        local reason = ok and (result.stderr or "") or tostring(result)
        reason = vim.trim(reason):sub(1, 200)
        if reason == "" then
          reason = "no valid response"
        end
        vim.schedule(function()
          vim.notify(
            "Kitty completion unavailable at "
              .. tostring(failed_socket)
              .. ": "
              .. reason
              .. "\nRetrying quietly; other completion sources still work."
              .. "\nAfter updating $KITTY_LISTEN_ON, use :CmpKittyReconnect to retry now.",
            vim.log.levels.WARN,
            { title = "cmp_kitty" }
          )
        end)
      end
      return empty
    end

    failures, retry_at = 0, 0
    return result.stdout or ""
  end

  -- Upstream calls get_text from a raw libuv timer; vim.system():wait() needs the main loop.
  kitty.get_text = vim.schedule_wrap(kitty.get_text)

  return reset
end

function M.setup()
  local source = require("cmp_kitty")
  local reset = M.attach(source.kitty)
  source:setup()
  vim.api.nvim_create_user_command("CmpKittyReconnect", function()
    reset()
    source.kitty.update_hold = false
    source.kitty:update()
  end, { desc = "Retry Kitty completion using the current KITTY_LISTEN_ON" })
end

return M
