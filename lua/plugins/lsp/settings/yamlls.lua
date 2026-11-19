--- yaml-language-server, with SchemaStore and content-based kubernetes schemas

local defaults = require("utils.lsp").lspconfig_defaults("yamlls")
local sc = require("schema-companion")

return function(opts)
  return sc.setup_client(
    sc.adapters.yamlls.setup({
      sources = {
        require("utils.kubernetes_schema").setup({ version = "master" }),
        sc.sources.lsp.setup(),
        sc.sources.none.setup(),
      },
    }),
    vim.tbl_deep_extend("force", opts, {
      -- schema-companion replaces on_init, so keep upstream's formatting capability hook
      on_init = defaults.on_init,
      settings = {
        yaml = {
          schemaStore = {
            -- use SchemaStore.nvim's catalog instead; an empty url avoids a server TypeError
            enable = false,
            url = "",
          },
          schemas = require("schemastore").yaml.schemas(),
        },
      },
    })
  )
end
