module.exports = {
  extends: ["@commitlint/config-conventional"],
  rules: {
    "scope-empty": [2, "never"],
    "scope-enum": [
      2,
      "always",
      [
        // entrypoints & bootstrap
        "core",
        "config",
        "lazy",
        // lsp / diagnostics / completion / syntax
        "lsp",
        "completion",
        "treesitter",
        // language & tooling support
        "rust",
        "coding",
        "dap",
        "db",
        // ui surface
        "ui",
        "colorscheme",
        "colorizer",
        "dashboard",
        "notifications",
        "files",
        "search",
        "terminal",
        "sessions",
        // writing & knowledge
        "wiki",
        "spell",
        "ai",
        // repo meta
        "deps",
        "docs",
        "help",
        "ci",
        "build",
        "tooling",
        "tests",
        "security",
      ],
    ],
  },
};
