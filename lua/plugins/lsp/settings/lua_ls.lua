return {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = {
          -- Make the server aware of Neovim runtime files
          library = vim.api.nvim_get_runtime_file("", true),
        },
      },
      doc = {
        privateName = { "^_" },
      },
      telemetry = {
        enable = false,
      },
    },
  },
}
