--- Unit tests for the utils module using Busted
--- See https://lunarmodules.github.io/busted/#usage
---
--- Author: @lararosekelley
--- Last Modified: August 28th, 2025

require("busted.runner")()

local assert = require("luassert")
local utils = require("lua.utils")

describe("utils module", function()
  it("should memoize a function", function()
    local count = 0

    local function add(a, b)
      count = count + 1
      return a + b
    end

    local memoized_add = utils.memoize(add)

    -- First call with (2, 3), should compute the result
    assert.equals(5, memoized_add(2, 3))
    assert.equals(1, count)

    -- Second call with (2, 3), should return cached result
    assert.equals(5, memoized_add(2, 3))
    assert.equals(1, count)

    -- Call with different arguments (4, 5), should compute again
    assert.equals(9, memoized_add(4, 5))
    assert.equals(2, count)

    -- Call again with (4, 5), should return cached result
    assert.equals(9, memoized_add(4, 5))
    assert.equals(2, count)
  end)
end)
