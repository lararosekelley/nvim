--- Database connection management
---
--- Author: @lararosekelley
--- Last Modified: August 23rd, 2025

return {
  -- database connection management. works best with treesitter configured for sql
  {
    "kndndrj/nvim-dbee",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>D", "<Cmd>lua require'dbee'.toggle()<CR>", desc = "Connect to Database" },
    },
    build = function()
      require("dbee").install()
    end,
    config = function()
      local dbee = require("dbee")
      local dbee_sources = require("dbee.sources")

      -- default: https://github.com/kndndrj/nvim-dbee/blob/master/lua/dbee/config.lua
      dbee.setup({
        sources = {
          dbee_sources.EnvSource:new("DBEE_CONNECTIONS"),
        },
        editor = {
          mappings = {
            {
              key = "<CR>",
              mode = "n",
              action = "run_file",
            },
          },
        },
      })
    end,
  },
}
