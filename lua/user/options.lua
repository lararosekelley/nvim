-- vim options

-- utf-8 encoding
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

-- system clipboard
vim.opt.clipboard = "unnamedplus"

-- enable mouse mode
vim.opt.mouse = "a"

-- longer history
vim.opt.history = 10000

-- spaces instead of tabs
vim.opt.tabstop = 2
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.smarttab = true

-- auto indentation
vim.opt.autoindent = true
vim.opt.smartindent = true

-- word wrapping
vim.opt.wrap = true
vim.opt.textwidth = 0
vim.opt.wrapmargin = 0
vim.opt.linebreak = true

-- max folds
vim.opt.foldnestmax = 10

-- language-specific folding
vim.opt.foldmethod = "indent"

-- display fold info
vim.opt.foldcolumn = "auto"

-- open folds when reading file
vim.opt.foldenable = false
vim.opt.foldlevelstart = 99

-- show line numbers
vim.opt.number = true
vim.opt.ruler = true

-- highlight matching braces
vim.opt.showmatch = true
vim.opt.matchtime = 2

-- don't warn about abandoned buffers
vim.opt.hidden = true

-- no concealing characters
vim.opt.conceallevel = 0

-- don't pass messages to completion menu
vim.opt.shortmess:append("c")

-- no swaps or backups
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false

-- persistent undo
vim.opt.undofile = true

-- don't automatically change current directory
vim.opt.autochdir = false

-- completion
vim.opt.completeopt = { "menuone", "noselect" }

-- terminal colors
vim.opt.termguicolors = true

-- preview commands before committing
vim.opt.inccommand = "split"

-- command window height
vim.opt.cmdheight = 1

-- show 120 line length marker
vim.opt.colorcolumn = "120"

-- dark bg
vim.opt.background = "dark"

-- highlight current line
vim.opt.cursorline = true

-- lazy redrawing
vim.opt.lazyredraw = true

-- terminal bell settings
vim.opt.errorbells = false
vim.opt.visualbell = true

-- show list chars
vim.opt.list = true
vim.opt.listchars = { tab = "> ", trail = "-", extends = ">", precedes = "<", nbsp = "+" }

-- show current command in bottom right
vim.opt.showcmd = true

-- show sign column
vim.opt.signcolumn = "yes"

-- lower esc key delay
vim.opt.timeoutlen = 1000
vim.opt.ttimeoutlen = 10

-- normalize backspace behavior
vim.opt.backspace = "indent,eol,start"

-- send more characters at once
vim.opt.ttyfast = true

-- split position after opening
vim.opt.splitright = true
vim.opt.splitbelow = true

-- wrap to prev/next lines when navigating
vim.opt.whichwrap:append("<,>,[,],h,l")

-- add padding when scrolling
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 10

-- grep-style regex
vim.opt.magic = true

-- default to /g flag in search
vim.opt.gdefault = true

-- highlight matches
vim.opt.hlsearch = true

-- ignore case in search
vim.opt.ignorecase = true

-- real-time search
vim.opt.incsearch = true

-- show tab and status bars
vim.opt.laststatus = 2
vim.opt.showtabline = 2
