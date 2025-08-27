--- Neovim homepage
---
--- Author: @lararosekelley
--- Last Modified: August 23rd, 2025

return {
  {
    "snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = [[
██╗  ██╗██╗       ██╗      █████╗ ██████╗  █████╗
██║  ██║██║       ██║     ██╔══██╗██╔══██╗██╔══██╗
███████║██║       ██║     ███████║██████╔╝███████║
██╔══██║██║       ██║     ██╔══██║██╔══██╗██╔══██║
██║  ██║██║▄█╗    ███████╗██║  ██║██║  ██║██║  ██║
╚═╝  ╚═╝╚═╝╚═╝    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝
          ]],
          ---@type snacks.dashboard.Item[]
          keys = {
            {
              icon = " ",
              key = "f",
              desc = "Find File",
              action = ":lua Snacks.dashboard.pick('files')",
            },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            {
              icon = "󰈞 ",
              key = "g",
              desc = "Find Text",
              action = ":lua Snacks.dashboard.pick('live_grep')",
            },
            {
              icon = " ",
              key = "r",
              desc = "Recent Files",
              action = ":lua Snacks.dashboard.pick('oldfiles')",
            },
            {
              key = "p",
              icon = "󰒋 ",
              desc = "Recent Projects",
              action = ":lua Snacks.dashboard.pick('projects')",
            },
            {
              icon = " ",
              key = "c",
              desc = "Config",
              action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
            },
            { icon = " ", key = "s", desc = "Restore Session", section = "session" },
            { icon = " ", key = "l", desc = "Plugins", action = ":Lazy" },
            { icon = "󰩈 ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
      },
    },
  },
}
