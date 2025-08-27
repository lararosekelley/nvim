--- Neovim homepage
---
--- Author: @lararosekelley
--- Last Modified: August 27th, 2025

local icons = require("config.icons").icons

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
          keys = {
            {
              icon = icons.dashboard.find_file,
              key = "f",
              desc = "Find File",
              action = ":lua Snacks.dashboard.pick('files')",
            },
            {
              icon = icons.dashboard.new_file,
              key = "n",
              desc = "New File",
              action = ":ene | startinsert",
            },
            {
              icon = icons.dashboard.find_text,
              key = "g",
              desc = "Find Text",
              action = ":lua Snacks.dashboard.pick('live_grep')",
            },
            {
              icon = icons.dashboard.recent_files,
              key = "r",
              desc = "Recent Files",
              action = ":lua Snacks.dashboard.pick('oldfiles')",
            },
            {
              icon = icons.dashboard.recent_projects,
              key = "p",
              desc = "Recent Projects",
              action = ":lua Snacks.dashboard.pick('projects')",
            },
            {
              icon = icons.dashboard.config,
              key = "c",
              desc = "Config",
              action = ":lua Snacks.dashboard.pick('files', { cwd = vim.fn.stdpath('config') })",
            },
            {
              icon = icons.dashboard.restore_session,
              key = "s",
              desc = "Restore Session",
              action = ":lua require('persistence').select()",
            },
            {
              icon = icons.dashboard.plugins,
              key = "l",
              desc = "Plugins",
              action = ":Lazy",
            },
            {
              icon = icons.dashboard.quit,
              key = "q",
              desc = "Quit",
              action = ":qa",
            },
          },
        },
      },
    },
  },
}
