--- typescript-language-server, for projects still on a JS TypeScript
---
--- It spawns `<typescript>/lib/tsserver.js`, which TypeScript 7 and the
--- `@typescript/typescript6` alias no longer ship. Projects on those get tsgo
--- instead, see settings/tsgo.lua.

local lsp = require("utils.lsp")

return {
  init_options = {
    maxTsServerMemory = 16384,
    preferences = {
      autoImportFileExcludePatterns = {},
      importModuleSpecifierPreference = "relative",
      importModuleSpecifierEnding = "minimal",
    },
  },
  root_dir = function(bufnr, on_dir)
    lsp.lspconfig_defaults("ts_ls").root_dir(bufnr, function(dir)
      if lsp.has_legacy_tsserver(dir) then
        on_dir(dir)
      end
    end)
  end,
}
