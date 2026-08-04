deps_dir := ".tests/site/pack/deps/start"

# Development
# -----------

# Install dependencies
install: install-js install-nvim

install-js:
    npm install

# Clone the Neovim plugins the test harness needs
install-nvim:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p {{ deps_dir }}
    clone() {
        local url="$1" dest="{{ deps_dir }}/$2"
        if [ -d "$dest" ]; then
            git -C "$dest" pull --quiet --ff-only
        else
            git clone --depth 1 --quiet "$url" "$dest"
        fi
    }
    clone https://github.com/nvim-lua/plenary.nvim plenary.nvim

clean:
    rm -rf .tests

# Testing
# -------

# Run all tests
test: install-nvim
    nvim --headless --noplugin -u spec/minimal_init.lua \
        -c "PlenaryBustedDirectory spec/ { minimal_init = 'spec/minimal_init.lua' }"

# Run a single spec file
test-file file: install-nvim
    nvim --headless --noplugin -u spec/minimal_init.lua \
        -c "PlenaryBustedFile {{ file }}"

# Code formatting
# ---------------

# Format, lint, and test everything
check: format lint test

# Format Lua code
format:
    stylua .

# Linting
# -------

# Lint Lua and Markdown
lint: lint-lua lint-md

lint-lua:
    stylua --check .
    selene lua spec

lint-md:
    npx markdownlint-cli2 "**/*.md"
    # Vale has no ignore config of its own, so the excludes live here. Without
    # them it lints the cloned test dependencies and node_modules.
    vale --glob='!{.tests,node_modules,.vale}/**' .
