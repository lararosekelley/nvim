--- Neovim options configuration
---
--- Author: @lararosekelley
--- Last Modified: August 27th, 2025

local opt = vim.opt

-- utf-8 encoding
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"

-- async i/o library
vim.uv = vim.uv or vim.loop

-- system clipboard
opt.clipboard = "unnamedplus"

-- enable mouse mode
opt.mouse = "a"
opt.mousemoveevent = true

-- longer history
opt.history = 10000

-- spellcheck
opt.spelllang = { "en" }

-- spaces instead of tabs
opt.tabstop = 2
opt.expandtab = true
opt.shiftwidth = 2
opt.shiftround = true
opt.smarttab = true

-- auto indentation
opt.autoindent = true
opt.smartindent = true

-- word wrapping
opt.wrap = true
opt.textwidth = 0
opt.wrapmargin = 0
opt.linebreak = true

-- max folds
opt.foldnestmax = 10

-- language-specific folding
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.require'utils'.foldexpr()"
opt.foldtext = ""

-- display fold info
opt.foldcolumn = "auto"

-- open folds when reading file
opt.foldenable = false
opt.foldlevelstart = 99

-- show line numbers
opt.number = true
opt.ruler = true

-- highlight matching braces
opt.showmatch = true
opt.matchtime = 2

-- don't warn about abandoned buffers
opt.hidden = true

-- no concealing characters
opt.conceallevel = 0

-- don't pass messages to completion menu
opt.shortmess:append("c")

-- no swaps or backups
opt.backup = false
opt.writebackup = false
opt.swapfile = false

-- persistent undo
opt.undofile = true
opt.undolevels = 10000

-- don't automatically change current directory
opt.autochdir = false

-- completion
opt.completeopt = { "menu", "menuone", "noselect" }

-- terminal colors
opt.termguicolors = true

-- preview commands before committing
opt.inccommand = "nosplit"

-- command window height
opt.cmdheight = 1

-- show 120 line length marker
opt.colorcolumn = "120"

-- dark bg
opt.background = "dark"

-- highlight current line
opt.cursorline = true

-- terminal bell settings
opt.errorbells = false
opt.visualbell = true

-- show list chars
opt.list = true
opt.listchars = { tab = "> ", trail = "-", extends = ">", precedes = "<", nbsp = "+" }

-- show current command in bottom right
opt.showcmd = true

-- show sign column
opt.signcolumn = "yes"

-- lower esc key delay
opt.timeoutlen = 1000
opt.ttimeoutlen = 10

-- normalize backspace behavior
opt.backspace = "indent,eol,start"

-- send more characters at once
opt.ttyfast = true

-- split position after opening
opt.splitright = true
opt.splitbelow = true

-- wrap to prev/next lines when navigating
opt.whichwrap:append("<,>,[,],h,l")

-- wild menu settings
opt.wildmode = "longest:full,full"

-- add padding when scrolling
opt.scrolloff = 10
opt.sidescrolloff = 10

-- smooth scrolling
opt.smoothscroll = true

-- grep-style regex
opt.magic = true
opt.formatoptions = "jcroqlnt"
opt.grepformat = "%f:%l:%c:%m"

-- default to /g flag in search
opt.gdefault = true

-- highlight matches
opt.hlsearch = true

-- ignore case in search
opt.ignorecase = true

-- real-time search
opt.incsearch = true

-- show tab and status bars
opt.laststatus = 2

-- update time
opt.updatetime = 200

-- ignore copilot when detecting lsp root
vim.g.root_lsp_ignore = { "copilot" }
