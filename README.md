# lararosekelley/nvim

> My Neovim configuration files

---

## Table of contents

1. [Installation](#installation)
2. [System requirements](#system-requirements)
3. [Project structure](#project-structure)
4. [Plugins](#plugins)
5. [Acknowledgements](#acknowledgements)
6. [License](#license)

## Installation

Clone this repository to your `~/.config/nvim/` directory:

```bash
git clone git@github.com:lararosekelley/nvim ~/.config/nvim
```

### Fonts

Install a font with support for icons on your system. I recommend using the `getnf`
utility to install a Nerd font. You can view the [getnf docs here](https://github.com/ronniedroid/getnf).

## System requirements

- [Neovim 0.8+](https://neovim.io)

### Languages

For full LSP support:

- C (with any compiler, such as `cc`, `clang`, `gcc`, or `zig`)
- Go
- Java (with `javac`)
- Julia
- Lua (with `luarocks`)
- Node.js (with `npm` and `yarn`)
- Ruby (with `gem`)
- Rust (with `cargo`)
- PHP (with `composer`)
- Python 3.9 (with `pip3`) installed in `~/.pyenv/versions/neovim3.13/bin/python`

### Neovim packages

For a few languages, additional "provider" packages are required:

- Node.js - `neovim`
- Python - `pynvim` (see above)
- Ruby - `neovim`

### Formatting tools

These should all be available on your `$PATH`, though local binaries will be used first if available.
See [lua/user/plugins/lsp/init.lua](./lua/user/plugins/lsp/init.lua) for configuration options.

- [black](https://github.com/psf/black)
- [google-java-format](https://github.com/google/google-java-format)
- [flake8](https://flake8.pycqa.org/en/latest)
- [markdownlint](https://github.com/igorshubovych/markdownlint-cli)
- [stylua](https://github.com/JohnnyMorganz/StyLua)
- [prettierd](https://github.com/fsouza/prettierd)

### Other tools

- `bash`
- `curl`
- [fd](https://github.com/sharkdp/fd)
- [fzf](https://github.com/junegunn/fzf)
- `git`
- `gzip`
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- `sh`
- `tar`
- [tmux](https://github.com/tmux/tmux)
- [tree-sitter](https://github.com/tree-sitter/tree-sitter)
- `wget`

When Neovim is next opened, plugins will be installed and configured automatically.

## Project structure

Configuration begins in the [init.lua](./init.lua) file, with most files living under The
[lua/user/](./lua/user) directory, broken up by purpose and plugin.

## Plugins

See full plugin configuration [here](./lua/user/plugins.lua).

## Acknowledgements

The [nvim-basic-ide](https://github.com/LunarVim/nvim-basic-ide) repository was used as a
reference while converting my old `.vimrc` to the Lua-based configuration.

## License

See [LICENSE](./LICENSE).
