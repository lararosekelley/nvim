;; extends
;; See https://tree-sitter.github.io/tree-sitter/3-syntax-highlighting.html?highlight=queries#queries

((identifier) @namespace.builtin
  (#eq? @namespace.builtin "vim"))

((identifier) @namespace.builtin
  (#eq? @namespace.builtin "Config"))
