--- helm-ls, which runs yaml-language-server itself for the yaml in chart templates

local sc = require("schema-companion")

return function(opts)
  return sc.setup_client(
    sc.adapters.helmls.setup({
      sources = {
        require("utils.kubernetes_schema").setup({ version = "master" }),
      },
    }),
    opts
  )
end
