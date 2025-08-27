--- Database connection management
---
--- Author: @lararosekelley
--- Last Modified: August 23rd, 2025

return {
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
      local dbee_sources = require("dbee.sources")

      require("dbee").setup({
        sources = dbee_sources.EnvSource:new("DBEE_CONNECTIONS"),
      })
    end,
  },
}
