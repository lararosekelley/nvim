--- Tests for the LSP helpers and the shape of the files they depend on

local helpers = require("spec.helpers")
local lsp = require("utils.lsp")
local spelling = require("utils.spelling")

describe("lsp.lsp_servers", function()
  it("holds no duplicates", function()
    local seen = {}

    for _, server in ipairs(lsp.lsp_servers) do
      assert.is_nil(seen[server], "duplicate server: " .. server)
      seen[server] = true
    end
  end)

  it("holds only non-empty strings", function()
    for i, server in ipairs(lsp.lsp_servers) do
      assert.equals("string", type(server), "entry " .. i .. " is not a string")
      assert.is_true(#server > 0, "entry " .. i .. " is empty")
    end
  end)
end)

describe("lsp.lsp_augroup", function()
  it("is a real augroup id", function()
    assert.equals("number", type(lsp.lsp_augroup))
    assert.is_true(lsp.lsp_augroup > 0)
  end)
end)

describe("lsp.lsp_format", function()
  local received
  local original_format

  before_each(function()
    received = nil
    original_format = vim.lsp.buf.format

    ---@diagnostic disable-next-line: duplicate-set-field
    vim.lsp.buf.format = function(opts)
      received = opts
    end
  end)

  after_each(function()
    vim.lsp.buf.format = original_format
  end)

  it("formats synchronously through null-ls only", function()
    lsp.lsp_format()

    assert.is_false(received.async)
    assert.is_true(received.filter({ name = "null-ls" }))
    assert.is_false(received.filter({ name = "lua_ls" }))
  end)
end)

describe("the ltex_plus settings file", function()
  -- The dictionary commands rewrite this file with a pattern match. If its
  -- shape drifts, they fail at runtime with "could not locate en-US dictionary
  -- block" and there is nothing else to catch it.
  local content

  before_each(function()
    local path = helpers.path("lua/plugins/lsp/settings/ltex_plus.lua")

    assert.equals(1, vim.fn.filereadable(path), "missing " .. path)
    content = table.concat(vim.fn.readfile(path), "\n")
  end)

  it("exposes an en-US dictionary block the transforms can find", function()
    local _, count = spelling.add_word(content, "spec-probe-word")

    assert.equals(1, count)
  end)

  it("still loads as Lua", function()
    local chunk, err = loadstring(content)

    assert.is_truthy(chunk, err)
  end)
end)
