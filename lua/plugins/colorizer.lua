--- Color highlighting for hex, rgb, hsl codes
---
--- Author: @lararosekelley
--- Last Modified: January 25th, 2026

return {
  {
    "NvChad/nvim-colorizer.lua",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      filetypes = {
        "css",
        "scss",
        "sass",
        "less",
        "html",
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "vue",
        "svelte",
        "astro",
        "json",
        "yaml",
        "toml",
        "lua",
        "vim",
        "conf",
      },
      user_default_options = {
        RGB = true,         -- #RGB hex codes
        RRGGBB = true,      -- #RRGGBB hex codes
        names = false,      -- "Name" codes like Blue (can be slow)
        RRGGBBAA = true,    -- #RRGGBBAA hex codes
        AARRGGBB = true,    -- 0xAARRGGBB hex codes
        rgb_fn = true,      -- CSS rgb() and rgba() functions
        hsl_fn = true,      -- CSS hsl() and hsla() functions
        css = true,         -- Enable all CSS features
        css_fn = true,      -- Enable all CSS *functions*
        mode = "background", -- "foreground", "background", or "virtualtext"
        tailwind = true,    -- Enable tailwind colors
        virtualtext = "",
      },
    },
  },
}
