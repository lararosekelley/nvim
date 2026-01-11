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
utility to install a Nerd Font.

You can view the [getnf docs here](https://github.com/ronniedroid/getnf).

After installing a Nerd Font, set your terminal emulator to use it.

## System requirements

- [Neovim 0.9+](https://neovim.io)

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
- Python 3.14+ (with `pip3`) installed in `~/.pyenv/versions/neovim3/bin/python`

### Neovim packages

For a few languages, additional "provider" packages are required:

- Node.js - `neovim`
- Python - `pynvim` (see above)
- Ruby - `neovim`

### Formatting tools

These should all be available on your `$PATH`, though local binaries will be used first if available.
See [lua/plugins/lsp/init.lua](./lua/plugins/lsp/init.lua) for configuration options.

- [black](https://github.com/psf/black)
- [google-java-format](https://github.com/google/google-java-format)
- [flake8](https://flake8.pycqa.org/en/latest)
- [markdownlint](https://github.com/igorshubovych/markdownlint-cli)
- [prettierd](https://github.com/fsouza/prettierd)
- [sqlfluff](https://github.com/sqlfluff/sqlfluff)
- [stylua](https://github.com/JohnnyMorganz/StyLua)

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
- [lazygit](https://github.com/jesseduffield/lazygit)
- [make](https://www.gnu.org/software/make)
- [tmux](https://github.com/tmux/tmux)
- [tree-sitter](https://github.com/tree-sitter/tree-sitter)
- `wget`
- [latex2text](https://pypi.org/project/pylatexenc)
- [mmdc](https://github.com/mermaid-js/mermaid-cli) (for Mermaid diagrams)

For terminal image previews:

- `chafa`
- [ueberzugpp](https://github.com/jstkdng/ueberzugpp)
- [viu](https://github.com/atanunq/viu)

When Neovim is next opened, plugins will be installed and configured automatically.

### Optional tools

For use of the [`cmp_kitty`](https://github.com/garyhurtz/cmp_kitty) completion source for `nvim-cmp`, you need to use the
Kitty terminal with one of the following lines in your `kitty.conf`:

```conf
allow_remote_control socket-only
allow_remote_control socket
allow_remote_control yes
```

Afterwards, set the socket Kitty will listen to by following the instructions
[here](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.listen_on). Example:

```conf
listen_on unix:@kitty
```

## Project structure

Configuration begins in the [init.lua](./init.lua) file, with most files living under the
[lua/](./lua) directory, broken up by purpose and plugin.

## Plugins

See full plugin configuration [here](./lua/plugins).

## Acknowledgements

The [nvim-basic-ide](https://github.com/LunarVim/nvim-basic-ide) repository was used as a
reference while converting my old `.vimrc` to the Lua-based configuration.

## License

See [LICENSE](./LICENSE).
