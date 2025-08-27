--- Coding assistants and project management
---
--- Author: @lararosekelley
--- Last Modified: August 27th, 2025

return {
  {
    "ahmedkhalf/project.nvim",
    event = "VeryLazy",
    opts = {
      -- order matters here
      detection_methods = { "pattern", "lsp" },
      -- package.json omitted to avoid defining a project in every Yarn workspace
      patterns = { ".git", ".hg", ".svn", ".bzr", "Makefile", ".wikiroot", "pyproject.toml" },
      -- set to true to print message on project detection
      silent_chdir = true,
      scope_chdir = "win",
      show_hidden = true,
    },
    config = function(_, opts)
      require("project_nvim").setup(opts)
    end,
  },
}
