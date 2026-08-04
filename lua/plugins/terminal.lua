--- Terminal and tmux navigration
---
--- Author: @lararosekelley
--- Last Modified: July 29th, 2026

local term_nav = require("utils").term_nav

return {
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    init = function()
      vim.g.tmux_navigator_no_mappings = 1
    end,
    config = function()
      local function nav(wincmd, dir)
        local prev = vim.api.nvim_get_current_win()
        vim.cmd("wincmd " .. wincmd)
        if vim.api.nvim_get_current_win() ~= prev then
          return -- moved within Neovim
        end
        -- At a split edge: cross into the surrounding multiplexer.
        if vim.env.HERDR_PANE_ID and vim.env.HERDR_PANE_ID ~= "" then
          local herdr = vim.env.HERDR_BIN_PATH
          if herdr == nil or herdr == "" then
            herdr = "herdr"
          end
          vim.fn.system({ herdr, "pane", "focus", "--direction", dir, "--current" })
        elseif vim.env.TMUX and vim.env.TMUX ~= "" then
          local tmux = { left = "Left", down = "Down", up = "Up", right = "Right" }
          pcall(vim.cmd, "TmuxNavigate" .. tmux[dir])
        end
      end

      local function map(lhs, wincmd, dir, desc)
        vim.keymap.set("n", lhs, function()
          nav(wincmd, dir)
        end, { silent = true, noremap = true, desc = desc })
      end

      map("<C-h>", "h", "left", "Navigate left (vim/herdr)")
      map("<C-j>", "j", "down", "Navigate down (vim/herdr)")
      map("<C-k>", "k", "up", "Navigate up (vim/herdr)")
      map("<C-l>", "l", "right", "Navigate right (vim/herdr)")
    end,
  },
  {
    "folke/snacks.nvim",
    opts = {
      terminal = {
        win = {
          keys = {
            nav_h = { "<C-h>", term_nav("h"), desc = "Go to Left Window", expr = true, mode = "t" },
            nav_j = { "<C-j>", term_nav("j"), desc = "Go to Lower Window", expr = true, mode = "t" },
            nav_k = { "<C-k>", term_nav("k"), desc = "Go to Upper Window", expr = true, mode = "t" },
            nav_l = { "<C-l>", term_nav("l"), desc = "Go to Right Window", expr = true, mode = "t" },
          },
        },
      },
    },
  },
}
