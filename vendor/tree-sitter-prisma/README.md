# tree-sitter-prisma (patched)

Vendored from [victorhqc/tree-sitter-prisma](https://github.com/victorhqc/tree-sitter-prisma)
at `3556b2c1f20ec9ac91e92d32c43d9d2a0ca3cc49` (v1.6.0, 2025-10-02), which is
also the revision nvim-treesitter pins. Upstream has been stalled since then and
does not parse constructs used in our schemas. A single ERROR node kills
highlighting for its whole enclosing block, so these gaps blank out entire models.

## Patches on top of upstream

1. `enum_block` accepts `block_attribute_declaration`, for `@@map` / `@@schema`
   inside `enum` bodies. Upstream only allows these in `statement_block`.
2. New `object` rule, added to `_constructable_expression`. Covers object literal
   attribute args, e.g. `@@index([a], where: { b: { not: null } })` from the
   `partialIndexes` preview feature.
3. `block_comment` added, mirroring open upstream PR #52. Covers `/** ... */`.
4. `number` accepts decimals, for `@default(1.0)`.

Patch 3 is upstream's own implementation, so it converges if #52 lands.

## Rebuilding

`src/parser.c` is pre-generated and committed, so installing needs only a C
compiler. After editing `grammar.js`:

    tree-sitter generate    # requires tree-sitter-cli >= 0.26.1
    tree-sitter test        # 26 upstream corpus tests, all should pass

Then `:TSInstall! prisma` in Neovim to recompile and reinstall.

`(block_comment) @comment` is missing from nvim-treesitter's shipped queries.
`queries/prisma/highlights.scm` in this config adds it.
