--- Integration of AI tools and plugins for enhanced coding assistance
---
--- Author: @lararosekelley
--- Last Modified: August 26th, 2026

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
}
