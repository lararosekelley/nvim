--- UI enhancements
---
--- Author: @lararosekelley
--- Last Modified: August 27th, 2025

local map = require("utils").map
local icons = require("config.icons").icons
local Snacks = require("snacks")

return {
  -- buffer/tab line
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    dependencies = {
      "catppuccin/nvim",
    },
    keys = {
      -- leader commands
      { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin" },
      { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete Non-Pinned Buffers" },
      { "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete Buffers to the Right" },
      { "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete Buffers to the Left" },
      -- buffer navigation
      { "<S-h>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev Buffer" },
      { "<S-l>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next Buffer" },
      -- prev
      { "[b", "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev Buffer" },
      { "[B", "<Cmd>BufferLineMovePrev<CR>", desc = "Move buffer prev" },
      -- next
      { "]b", "<Cmd>BufferLineCycleNext<CR>", desc = "Next Buffer" },
      { "]B", "<Cmd>BufferLineMoveNext<CR>", desc = "Move buffer next" },
    },
    opts = {
      highlights = require("catppuccin.groups.integrations.bufferline").get_theme(),
      options = {
        separator_style = "slant",
        hover = {
          enabled = true,
          delay = 200,
          reveal = { "close" },
        },
        diagnostics = "nvim_lsp",
        always_show_bufferline = false,
        show_tab_indicators = true,
        diagnostics_indicator = function(_, _, diag)
          return vim.trim(
            (diag.error and icons.diagnostics.Error .. diag.error .. " " or "")
              .. (diag.warning and icons.diagnostics.Warn .. diag.warning or "")
          )
        end,
        offsets = {
          {
            filetype = "snacks_layout_box",
            text = icons.misc.folder .. "File Explorer",
            separator = true,
          },
        },
        get_element_icon = function(opts)
          return icons.ft[opts.filetype]
        end,
      },
    },
  },
  -- statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "AndreM222/copilot-lualine",
      {
        "lewis6991/gitsigns.nvim",
        opts = {
          current_line_blame = true,
        },
      },
    },
    event = "VeryLazy",
    init = function()
      vim.g.lualine_laststatus = vim.o.laststatus

      -- if any open files, hide lualine until loaded. otherwise, hide on start page
      if vim.fn.argc(-1) > 0 then
        vim.o.statusline = " "
      else
        vim.o.laststatus = 0
      end
    end,
    opts = function()
      -- improves performance by not loading lualine_require
      local lualine_require = require("lualine_require")
      lualine_require.require = require

      vim.o.laststatus = vim.g.lualine_laststatus

      -- conditions for use in lualine
      local conditions = {
        buffer_not_empty = function()
          return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
        end,
        hide_in_width = function()
          return vim.fn.winwidth(0) > 120
        end,
      }

      -- lualine components
      local progress = { "progress", separator = " ", padding = { left = 2, right = 0 } }
      local location = { "location", padding = { left = 0, right = 1 } }
      local function datetime()
        return icons.misc.time .. os.date("%R")
      end
      local filename = {
        "filename",
        file_stautus = false,
        newfile_status = false,
        path = 1,
        cond = conditions.hide_in_width,
      }
      local diagnostics = {
        "diagnostics",
        symbols = {
          error = icons.diagnostics.Error,
          warn = icons.diagnostics.Warn,
          info = icons.diagnostics.Info,
          hint = icons.diagnostics.Hint,
        },
      }
      local filetype = {
        "filetype",
        icon_only = true,
        separator = "",
        padding = {
          left = 1,
          right = 0,
        },
      }
      local copilot = {
        "copilot",
        show_colors = true,
        show_loading = true,
        symbols = {
          spinners = "dots",
          status = {
            hl = {
              enabled = Snacks.util.color("DiagnosticVirtualTextInfo"),
              disabled = Snacks.util.color("CmpGhostText"),
              sleep = Snacks.util.color("CmpGhostText"),
              warning = Snacks.util.color("DiagnosticVirtualTextWarn"),
              unknown = Snacks.util.color("DiagnosticVirtualTextError"),
            },
          },
        },
      }

      local opts = {
        options = {
          theme = "auto",
          globalstatus = vim.o.laststatus == 3,
          disabled_filetypes = { statusline = { "dashboard", "alpha", "ministarter", "snacks_dashboard" } },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch" },
          lualine_c = { filename, diagnostics, filetype },
          lualine_x = {
            copilot,
            Snacks.profiler.status(),
            {
              function()
                return require("noice").api.status.command.get()
              end,
              cond = function()
                return package.loaded["noice"] and require("noice").api.status.command.has()
              end,
              color = function()
                return { fg = Snacks.util.color("Statement") }
              end,
            },
            {
              function()
                return require("noice").api.status.mode.get()
              end,
              cond = function()
                return package.loaded["noice"] and require("noice").api.status.mode.has()
              end,
              color = function()
                return { fg = Snacks.util.color("Constant") }
              end,
            },
            {
              function()
                return " " .. require("dap").status()
              end,
              cond = function()
                return package.loaded["dap"] and require("dap").status() ~= ""
              end,
              color = function()
                return { fg = Snacks.util.color("Debug") }
              end,
            },
            {
              require("lazy.status").updates,
              cond = require("lazy.status").has_updates,
              color = function()
                return { fg = Snacks.util.color("Special") }
              end,
            },
            {
              "diff",
              symbols = {
                added = icons.git.added,
                modified = icons.git.modified,
                removed = icons.git.removed,
              },
              source = function()
                local gitsigns = vim.b.gitsigns_status_dict

                if gitsigns then
                  return {
                    added = gitsigns.added,
                    modified = gitsigns.changed,
                    removed = gitsigns.removed,
                  }
                end
              end,
            },
          },
          lualine_y = { progress, location },
          lualine_z = { datetime },
        },
        extensions = { "neo-tree", "lazy", "fzf" },
      }

      return opts
    end,
  },
  -- general utility library
  {
    "snacks.nvim",
    opts = {
      indent = { enabled = true },
      input = { enabled = true },
      notifier = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = false }, -- we set this in options.lua
      toggle = { map = map },
      words = { enabled = true },
    },
  },
  -- nice ui components
  { "MunifTanjim/nui.nvim", event = "VeryLazy" },
  -- nerd font explorer
  {
    "2kabhishek/nerdy.nvim",
    event = "VeryLazy",
    dependencies = {
      "folke/snacks.nvim",
    },
    cmd = "Nerdy",
    opts = {
      max_recents = 30,
      add_default_keybindings = false,
      copy_to_clipboard = false,
    },
  },
  -- icons
  {
    "nvim-tree/nvim-web-devicons",
    event = "VeryLazy",
    opts = {},
  },
}
