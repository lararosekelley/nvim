--- Utility functions and handlers for LSP servers
---
--- Author: @lararosekelley
--- Last Modified: September 7th, 2025

local icons = require("config.icons").icons

local M = {}

local status_cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not status_cmp_ok then
  return
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()
M.capabilities.textDocument.completion.completionItem.snippetSupport = true
M.capabilities = cmp_nvim_lsp.default_capabilities(M.capabilities)

M.setup = function()
  vim.diagnostic.config({
    virtual_text = false, -- show in-line diagnostics
    signs = {
      -- per-severity icons in the sign column
      text = {
        [vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
        [vim.diagnostic.severity.WARN]  = icons.diagnostics.Warn,
        [vim.diagnostic.severity.HINT]  = icons.diagnostics.Hint,
        [vim.diagnostic.severity.INFO]  = icons.diagnostics.Info,
      },
      -- OPTIONAL: keep number-column highlights similar to old texthl groups
      numhl = {
        [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
        [vim.diagnostic.severity.WARN]  = "DiagnosticSignWarn",
        [vim.diagnostic.severity.HINT]  = "DiagnosticSignHint",
        [vim.diagnostic.severity.INFO]  = "DiagnosticSignInfo",
      },
      -- You can also add linehl = { [sev] = "YourLineHLGroup", ... } if you want.
    },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
      focusable = false, -- set true to disable auto-close
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  })

  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded",
  })

  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "rounded",
  })
end

M.on_attach = function(client, _)
  local disable_formatting_clients = { ts_ls = true, lua_ls = true }

  if disable_formatting_clients[client.name] then
    client.server_capabilities.document_formatting = false
  end

  local status_ok, illuminate = pcall(require, "illuminate")
  if not status_ok then
    return
  end

  illuminate.on_attach(client)
end

return M
