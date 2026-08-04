--- Tests for the general-purpose utility helpers

local helpers = require("spec.helpers")
local utils = require("utils")

describe("utils.memoize", function()
  before_each(function()
    utils.cache = {}
  end)

  it("computes once per distinct argument list", function()
    local count = 0

    local add = utils.memoize(function(a, b)
      count = count + 1
      return a + b
    end)

    assert.equals(5, add(2, 3))
    assert.equals(1, count)

    assert.equals(5, add(2, 3))
    assert.equals(1, count)

    assert.equals(9, add(4, 5))
    assert.equals(2, count)

    assert.equals(9, add(4, 5))
    assert.equals(2, count)
  end)

  it("keys on the whole argument list, not just the first", function()
    local calls = 0

    local concat = utils.memoize(function(a, b)
      calls = calls + 1
      return a .. b
    end)

    assert.equals("ab", concat("a", "b"))
    assert.equals("ac", concat("a", "c"))
    assert.equals(2, calls)
  end)

  it("distinguishes arguments that stringify alike", function()
    local calls = 0

    local identity = utils.memoize(function(v)
      calls = calls + 1
      return v
    end)

    identity(1)
    identity("1")

    assert.equals(2, calls)
  end)

  it("gives each wrapped function its own cache", function()
    local one = utils.memoize(function()
      return 1
    end)
    local two = utils.memoize(function()
      return 2
    end)

    assert.equals(1, one())
    assert.equals(2, two())
  end)
end)

describe("utils.remove_at", function()
  it("drops the element at the given index", function()
    assert.same({ "a", "c" }, utils.remove_at({ "a", "b", "c" }, 2))
  end)

  it("drops the first and last elements", function()
    assert.same({ "b", "c" }, utils.remove_at({ "a", "b", "c" }, 1))
    assert.same({ "a", "b" }, utils.remove_at({ "a", "b", "c" }, 3))
  end)

  it("returns a copy when the index is out of range", function()
    assert.same({ "a", "b" }, utils.remove_at({ "a", "b" }, 9))
  end)

  it("does not mutate the input", function()
    local input = { "a", "b", "c" }

    utils.remove_at(input, 2)

    assert.same({ "a", "b", "c" }, input)
  end)

  it("handles an empty list", function()
    assert.same({}, utils.remove_at({}, 1))
  end)
end)

describe("utils.file_exists", function()
  it("finds a file that is there", function()
    assert.is_true(utils.file_exists(helpers.path("init.lua")))
  end)

  it("rejects a file that is not", function()
    assert.is_false(utils.file_exists("/nonexistent/nope.lua"))
  end)

  it("also reports true for a directory", function()
    -- io.open succeeds on a directory on Linux, so the helper is really
    -- "openable" rather than "is a file". Pinned because callers that need the
    -- stricter meaning have to use vim.fn.filereadable instead.
    assert.is_true(utils.file_exists("/tmp"))
  end)
end)

describe("utils.dump", function()
  it("renders scalars via tostring", function()
    assert.equals("1", utils.dump(1))
    assert.equals("hello", utils.dump("hello"))
    assert.equals("true", utils.dump(true))
  end)

  it("quotes non-numeric keys", function()
    assert.equals('{ ["a"] = 1,} ', utils.dump({ a = 1 }))
  end)

  it("leaves numeric keys unquoted", function()
    assert.equals("{ [1] = a,} ", utils.dump({ "a" }))
  end)

  it("recurses into nested tables", function()
    assert.equals('{ ["a"] = { ["b"] = 1,} ,} ', utils.dump({ a = { b = 1 } }))
  end)
end)

describe("utils.map", function()
  local mode, lhs, rhs, opts
  local original_set

  before_each(function()
    mode, lhs, rhs, opts = nil, nil, nil, nil
    original_set = vim.keymap.set

    ---@diagnostic disable-next-line: duplicate-set-field
    vim.keymap.set = function(m, l, r, o)
      mode, lhs, rhs, opts = m, l, r, o
    end
  end)

  after_each(function()
    vim.keymap.set = original_set
  end)

  it("defaults to a silent, non-recursive mapping", function()
    utils.map("n", "<leader>x", "<cmd>echo 1<cr>")

    assert.equals("n", mode)
    assert.equals("<leader>x", lhs)
    assert.equals("<cmd>echo 1<cr>", rhs)
    assert.is_true(opts.silent)
    assert.is_true(opts.noremap)
  end)

  it("lets callers override the defaults", function()
    utils.map("n", "<leader>x", "y", { silent = false, desc = "thing" })

    assert.is_false(opts.silent)
    assert.is_true(opts.noremap)
    assert.equals("thing", opts.desc)
  end)
end)
