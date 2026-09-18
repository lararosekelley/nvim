local completion = require("utils.kitty_completion")

describe("Kitty completion connection guard", function()
  local originals, environment, kitty, reset, now, response, calls, scheduled, notifications

  local function flush()
    local pending = scheduled
    scheduled = {}
    for _, callback in ipairs(pending) do
      callback()
    end
  end

  local function execute(command)
    return kitty:execute_kitty_command(kitty:build_kitty_command(command or "ls"))
  end

  before_each(function()
    originals = {
      system = vim.system,
      hrtime = vim.uv.hrtime,
      executable = vim.fn.executable,
      schedule = vim.schedule,
      notify = vim.notify,
    }
    environment = {
      TMUX = vim.env.TMUX,
      KITTY_WINDOW_ID = vim.env.KITTY_WINDOW_ID,
      KITTY_LISTEN_ON = vim.env.KITTY_LISTEN_ON,
    }
    vim.env.TMUX = nil
    vim.env.KITTY_WINDOW_ID = "1"
    vim.env.KITTY_LISTEN_ON = "unix:@kitty-old"
    now, calls, scheduled, notifications = 0, {}, {}, {}
    response = { code = 1, stdout = "", stderr = "connect: connection refused" }
    vim.uv.hrtime = function()
      return now * 1e6
    end
    vim.fn.executable = function()
      return 1
    end
    vim.system = function(argv, opts)
      calls[#calls + 1] = { argv = argv, opts = opts }
      return {
        wait = function()
          return response
        end,
      }
    end
    vim.schedule = function(callback)
      scheduled[#scheduled + 1] = callback
    end
    vim.notify = function(message)
      notifications[#notifications + 1] = message
    end
    kitty = { config = {}, get_text = function() end }
    reset = completion.attach(kitty)
  end)

  after_each(function()
    vim.system = originals.system
    vim.uv.hrtime = originals.hrtime
    vim.fn.executable = originals.executable
    vim.schedule = originals.schedule
    vim.notify = originals.notify
    vim.env.TMUX = environment.TMUX
    vim.env.KITTY_WINDOW_ID = environment.KITTY_WINDOW_ID
    vim.env.KITTY_LISTEN_ON = environment.KITTY_LISTEN_ON
  end)

  it("does not load the source without a Kitty endpoint, in tmux, or without kitty", function()
    vim.env.KITTY_LISTEN_ON = nil
    assert.is_false(completion.enabled())
    vim.env.KITTY_LISTEN_ON = "unix:@kitty-old"
    vim.env.TMUX = "/tmp/tmux"
    assert.is_false(completion.enabled())
    vim.env.TMUX = nil
    vim.fn.executable = function()
      return 0
    end
    assert.is_false(completion.enabled())
  end)

  it("uses argv and captures stderr with a bounded timeout", function()
    vim.env.KITTY_LISTEN_ON = "unix:/tmp/a socket"
    response = { code = 0, stdout = "[]", stderr = "" }
    assert.equals("[]", execute())
    assert.same({ "kitty", "@", "--to", "unix:/tmp/a socket", "ls" }, calls[1].argv)
    assert.same({ text = true, timeout = 250 }, calls[1].opts)
  end)

  it("warns once and makes no requests during exponential backoff", function()
    assert.equals("[]", execute())
    assert.is_false(kitty:is_available())
    for _ = 1, 100 do
      assert.equals("", execute("get-text"))
    end
    assert.equals(1, #calls)
    now = 4999
    assert.is_false(kitty:is_available())
    now = 5000
    assert.is_true(kitty:is_available())
    execute()
    now = 14999
    assert.is_false(kitty:is_available())
    now = 15000
    assert.is_true(kitty:is_available())
    execute()
    flush()
    assert.equals(3, #calls)
    assert.equals(1, #notifications)
    assert.matches("connection refused", notifications[1], 1, true)
  end)

  it("caps backoff at one minute even after repeated failures", function()
    for _ = 1, 10 do
      assert.is_true(kitty:is_available())
      execute()
      now = now + 60000
    end
    assert.equals(10, #calls)
    flush()
    assert.equals(1, #notifications)
  end)

  it("recovers automatically on the next attempt after a transient failure", function()
    execute()
    now = 5000
    response = { code = 0, stdout = '[{"id":1}]', stderr = "" }
    assert.equals('[{"id":1}]', execute())
    assert.is_true(kitty:is_available())
    response = { code = 1, stdout = "", stderr = "refused again" }
    execute()
    now = 10000
    assert.is_true(kitty:is_available())
    flush()
    assert.equals(1, #notifications)
  end)

  it("immediately picks up a refreshed endpoint or explicit reconnect", function()
    execute()
    vim.env.KITTY_LISTEN_ON = "unix:@kitty-new"
    assert.is_true(kitty:is_available())
    execute()
    assert.equals("unix:@kitty-new", calls[2].argv[4])
    assert.is_false(kitty:is_available())
    reset()
    assert.is_true(kitty:is_available())
  end)

  it("tolerates spawn errors, timeouts and malformed ls without crashing callers", function()
    for _, result in ipairs({
      { code = 124, stdout = "", stderr = "timeout" },
      { code = 0, stdout = "not json", stderr = "" },
      { code = 0, stdout = '{"error":"unauthorized"}', stderr = "" },
    }) do
      reset()
      response = result
      assert.equals("[]", execute())
      assert.is_false(kitty:is_available())
    end
    reset()
    vim.system = function()
      error("ENOENT")
    end
    assert.equals("[]", execute())
    assert.equals("", execute("select-window"))
  end)

  it("does not treat an empty successful window read as a connection error", function()
    response = { code = 0, stdout = "", stderr = "" }
    assert.equals("", execute("get-text"))
    assert.is_true(kitty:is_available())
    flush()
    assert.equals(0, #notifications)
  end)

  it("schedules window reads outside the upstream libuv timer callback", function()
    local received
    local instance = {
      config = {},
      get_text = function(self, wid)
        received = { self, wid }
      end,
    }
    completion.attach(instance)
    instance:get_text(42)
    assert.is_nil(received)
    flush()
    assert.same({ instance, 42 }, received)
  end)
end)
