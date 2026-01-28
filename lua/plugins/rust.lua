--- Rust development plugins
---
--- Author: @lararosekelley

return {
  {
    "mrcjkb/rustaceanvim",
    version = "^6",
    lazy = false,
    ft = { "rust" },
    init = function()
      local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/rust-analyzer"
      vim.g.rustaceanvim = {
        server = {
          cmd = function()
            if vim.fn.executable(mason_bin) == 1 then
              return { mason_bin }
            else
              return { "rust-analyzer" }
            end
          end,
          default_settings = {
            ["rust-analyzer"] = {
              checkOnSave = {
                command = "clippy",
              },
            },
          },
        },
      }
    end,
  },
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    opts = {},
  },
}
