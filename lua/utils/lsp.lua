--- LSP-specific utility functions for Neovim configuration
---
--- Author: @lararosekelley
--- Last Modified: August 27th, 2025

local M = {}

---@type table<string>
M.lsp_servers = {
  "bashls",
  "clangd",
  "cssmodules_ls",
  "dockerls",
  "eslint",
  "gopls",
  "graphql",
  "html",
  "jdtls",
  "jsonls",
  "ltex_plus",
  "perlnavigator",
  "prismals",
  "pyright",
  "solargraph",
  "sqlls",
  "lua_ls",
  "oxlint",
  "stylelint_lsp",
  "svelte",
  "tailwindcss",
  "terraformls",
  "ts_ls",
  "tsgo",
  "vimls",
  "yamlls",
}

---@type integer
M.lsp_augroup = vim.api.nvim_create_augroup("LspFormatOnSave", {})

--- Read a server's config as nvim-lspconfig ships it, before any of ours is merged in
---
--- `vim.lsp.config[name]` returns the merged config, so reading it to wrap an
--- upstream default would wrap our own wrapper the second time the plugin's
--- config function runs. Reading the file keeps that idempotent.
---
--- @param server string
--- @return table
M.lspconfig_defaults = function(server)
  local file = vim.api.nvim_get_runtime_file("lsp/" .. server .. ".lua", false)[1]

  if not file then
    return {}
  end

  local ok, config = pcall(dofile, file)

  return (ok and type(config) == "table") and config or {}
end

--- Major version of the typescript package a `node_modules/.bin` entry resolves to
---
--- @param bin string
--- @return integer
local function ts_bin_major(bin)
  local real = vim.uv.fs_realpath(bin)

  if not real then
    return 0
  end

  -- <pkg>/bin/<name> -> <pkg>/package.json
  local manifest = vim.fs.joinpath(vim.fs.dirname(vim.fs.dirname(real)), "package.json")
  local ok, lines = pcall(vim.fn.readfile, manifest)

  if not ok then
    return 0
  end

  local decoded, json = pcall(vim.json.decode, table.concat(lines, "\n"))

  return (decoded and tonumber(tostring(json.version):match("^(%d+)"))) or 0
end

--- Does a project's typescript still ship the `lib/tsserver.js` that ts_ls spawns?
---
--- TypeScript 7 is a native binary and ships no JS libs at all, and the
--- `@typescript/typescript6` alias package drops tsserver.js too. ts_ls exits with
--- "Could not find a valid TypeScript installation" against either, so it is only
--- worth starting where the legacy entrypoint exists.
---
--- @param root string|nil
--- @return boolean
M.has_legacy_tsserver = function(root)
  if not root then
    return false
  end

  local tsserver = vim.fs.joinpath(root, "node_modules", "typescript", "lib", "tsserver.js")

  return vim.uv.fs_stat(tsserver) ~= nil
end

--- Path to a binary that can serve TypeScript 7's native LSP over `--lsp --stdio`
---
--- Prefers the project's own copy, since a repo pins its compiler: the released
--- `typescript` package publishes it as `tsc`, `@typescript/native-preview` as
--- `tsgo`. Falls back to the `tsgo` mason installs.
---
--- @param root string|nil
--- @return string|nil
M.ts_native_bin = function(root)
  if root then
    for _, name in ipairs({ "tsgo", "tsc" }) do
      local bin = vim.fs.joinpath(root, "node_modules", ".bin", name)

      if vim.fn.executable(bin) == 1 and ts_bin_major(bin) >= 7 then
        return bin
      end
    end
  end

  return vim.fn.executable("tsgo") == 1 and "tsgo" or nil
end

--- Only format with none-ls
---
--- @return nil
M.lsp_format = function()
  vim.lsp.buf.format({
    filter = function(client)
      return client.name == "null-ls"
    end,
    async = false,
  })
end

return M
