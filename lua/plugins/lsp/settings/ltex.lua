return {
  filetypes = {
    "bib",
    "gitcommit",
    "markdown",
    "mdx",
    "org",
    "plaintex",
    "rst",
    "rnoweb",
    "tex",
    "text",
    "pandoc",
    "quarto",
    "rmd",
    "context",
    "vimwiki",
  },
  settings = {
    ltex = {
      language = "en-US",
      checkFrequency = "save",
      additionalRules = {
        enablePickyRules = false,
      },
      dictionary = {
        ["en-US"] = { "Higharc", "LLM", "LLMs", "CTO", "OpenCode", "Neovim" },
      },
    },
  },
}
