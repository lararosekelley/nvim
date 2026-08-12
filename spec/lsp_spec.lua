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

describe("lsp.has_legacy_tsserver", function()
  local root

  before_each(function()
    root = vim.fn.tempname()
    vim.fn.mkdir(root .. "/node_modules/typescript/lib", "p")
  end)

  after_each(function()
    vim.fn.delete(root, "rf")
  end)

  it("is false without a root", function()
    assert.is_false(lsp.has_legacy_tsserver(nil))
  end)

  it("is false when typescript ships no tsserver.js", function()
    assert.is_false(lsp.has_legacy_tsserver(root))
  end)

  it("is true when typescript ships tsserver.js", function()
    vim.fn.writefile({ "" }, root .. "/node_modules/typescript/lib/tsserver.js")

    assert.is_true(lsp.has_legacy_tsserver(root))
  end)
end)

describe("lsp.ts_native_bin", function()
  local root

  --- Stand up node_modules/.bin/<name> pointing at a typescript package of `version`
  local function fake_bin(name, version)
    local pkg = root .. "/node_modules/" .. name .. "-pkg"

    vim.fn.mkdir(pkg .. "/bin", "p")
    vim.fn.mkdir(root .. "/node_modules/.bin", "p")
    vim.fn.writefile({ '{"version":"' .. version .. '"}' }, pkg .. "/package.json")
    vim.fn.writefile({ "#!/bin/sh" }, pkg .. "/bin/" .. name)
    vim.fn.setfperm(pkg .. "/bin/" .. name, "rwxr-xr-x")
    vim.uv.fs_symlink(pkg .. "/bin/" .. name, root .. "/node_modules/.bin/" .. name)
  end

  before_each(function()
    root = vim.fn.tempname()
    vim.fn.mkdir(root, "p")
  end)

  after_each(function()
    vim.fn.delete(root, "rf")
  end)

  it("uses the project's own binary when it is TypeScript 7 or newer", function()
    fake_bin("tsc", "7.0.2")

    assert.equals(root .. "/node_modules/.bin/tsc", lsp.ts_native_bin(root))
  end)

  it("prefers tsgo over tsc", function()
    fake_bin("tsc", "7.0.2")
    fake_bin("tsgo", "7.0.0-dev.1")

    assert.equals(root .. "/node_modules/.bin/tsgo", lsp.ts_native_bin(root))
  end)

  it("skips a local binary from an older TypeScript, which has no --lsp", function()
    fake_bin("tsc", "5.9.3")

    assert.not_equals(root .. "/node_modules/.bin/tsc", lsp.ts_native_bin(root))
  end)
end)

describe("lsp.lspconfig_defaults", function()
  -- nvim-lspconfig is not on the harness runtimepath, so stand in for it
  local plugin
  local server = "spec_probe_server"

  before_each(function()
    plugin = vim.fn.tempname()

    vim.fn.mkdir(plugin .. "/lsp", "p")
    vim.fn.writefile({ 'return { cmd = { "probe" } }' }, plugin .. "/lsp/" .. server .. ".lua")
    vim.opt.runtimepath:prepend(plugin)
  end)

  after_each(function()
    vim.opt.runtimepath:remove(plugin)
    vim.fn.delete(plugin, "rf")
  end)

  it("is empty for a server with no config on the runtimepath", function()
    assert.same({}, lsp.lspconfig_defaults("no_such_server"))
  end)

  it("reads the shipped config", function()
    assert.same({ "probe" }, lsp.lspconfig_defaults(server).cmd)
  end)

  it("reads the file rather than the merged config, so wrapping stays idempotent", function()
    -- the ts_ls and tsgo settings wrap the upstream root_dir; were this the merged
    -- config it would hand back our own wrapper and recurse
    vim.lsp.config(server, { cmd = { "ours" } })

    assert.same({ "probe" }, lsp.lspconfig_defaults(server).cmd)
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
