--- TypeScript 7's native language server
---
--- Takes over from ts_ls wherever the project's typescript has no `lib/tsserver.js`
--- for ts_ls to spawn: TypeScript 7 installs, the `@typescript/typescript6` alias,
--- and projects with no local typescript at all.

local lsp = require("utils.lsp")

return {
  cmd = function(dispatchers, config)
    local bin = lsp.ts_native_bin((config or {}).root_dir) or "tsgo"

    return vim.lsp.rpc.start({ bin, "--lsp", "--stdio" }, dispatchers)
  end,
  root_dir = function(bufnr, on_dir)
    lsp.lspconfig_defaults("tsgo").root_dir(bufnr, function(dir)
      if not lsp.has_legacy_tsserver(dir) and lsp.ts_native_bin(dir) then
        on_dir(dir)
      end
    end)
  end,
}
