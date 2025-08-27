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
  "ltex",
  "perlnavigator",
  "prismals",
  "pyright",
  "solargraph",
  "sqlls",
  "lua_ls",
  "stylelint_lsp",
  "svelte",
  "tailwindcss",
  "terraformls",
  "ts_ls",
  "vimls",
  "vuels",
  "yamlls",
}

---@type integer
M.lsp_augroup = vim.api.nvim_create_augroup("LspFormatOnSave", {})

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
