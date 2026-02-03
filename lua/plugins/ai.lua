--- Integration of AI tools and plugins for enhanced coding assistance
---
--- Author: @lararosekelley
--- Last Modified: November 17th, 2025

return {
  -- avante
  {
    "yetone/avante.nvim",
    enabled = false, -- TODO: enable once auto suggestions behavior feels right
    event = "VeryLazy",
    build = "make",
    version = false,
    opts = {
      instructions_file = "docs/ROBOTS.md",
      provider = "claude",
      auto_suggestions_provider = "claude",
      providers = {
        claude = {
          endpoint = "https://api.anthropic.com",
          model = "claude-sonnet-4-20250514",
          timeout = 30000, -- Timeout in milliseconds
          extra_request_body = {
            temperature = 0.75,
            max_tokens = 20480,
          },
        },
        copilot = {
          model = "gpt-5",
        },
      },
      behaviour = {
        auto_suggestions = false, -- enable for automatic code suggestions
      },
      windows = {
        position = "right",
      },
      file_selector = {
        provider = "snacks",
      },
      input = {
        provider = "snacks",
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "zbirenbaum/copilot.lua",
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },
  -- copilot
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    event = "BufReadPost",
    opts = {
      -- attach to buffer
      should_attach = function(bufnr)
        local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
        local disabled_filetypes = {} -- add disabled filetypes here

        if vim.tbl_contains(disabled_filetypes, filetype) then
          return false
        end

        return true
      end,
      -- handled by nvim-cmp / blink.cmp
      suggestion = {
        enabled = false,
      },
      -- handled by nvim-cmp / blink.cmp
      panel = {
        enabled = false,
      },
      -- filetypes to enable or disable in
      filetypes = {
        markdown = false,
      },
    },
  },
}
