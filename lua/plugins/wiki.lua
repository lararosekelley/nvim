--- Local wiki editing in Vim
---
--- Author: @lararosekelley
--- Last Modified: August 27th, 2025

return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {},
  },
  {
    "echaya/neowiki.nvim",
    opts = {
      wiki_dirs = {
        { name = "Personal", path = os.getenv("VIM_WIKI_ROOT") or (vim.uv.os_homedir() .. "/notes") },
      },
    },
    keys = {
      { "<leader>Wo", "<cmd>lua require('neowiki').open_wiki()<cr>", desc = "Open Wiki" },
      { "<leader>Wf", "<cmd>lua require('neowiki').open_wiki_floating()<cr>", desc = "Open Wiki in Floating Window" },
      { "<leader>Wt", "<cmd>lua require('neowiki').open_wiki_new_tab()<cr>", desc = "Open Wiki in Tab" },
    },
  },
}
