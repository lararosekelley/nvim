local lazy_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazy_path) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazy_path,
	})
end

vim.opt.rtp:prepend(lazy_path)

-- sync plugins when this plugins file is updated
vim.cmd([[
  augroup ReloadLazyPlugins
    autocmd!
    autocmd BufWritePost lazy.lua source <afile> | Lazy sync
  augroup end
]])

-- don't error on first use of lazy
local status_ok, lazy = pcall(require, "lazy")
if not status_ok then
	return
end

local opts = {
	checker = {
		enabled = true,
	},
}

local plugins = {
	-- color scheme
	{
		"rafi/awesome-vim-colorschemes",
		lazy = false,
		priority = 1000, -- must be highest
		config = function()
			vim.cmd([[colorscheme gruvbox]])
		end,
	},
	-- neovim
	"nvim-lua/plenary.nvim", -- neovim functions
	"lewis6991/impatient.nvim", -- faster startup time
	"tpope/vim-eunuch", -- unix commands in vim

	-- comments
	"numToStr/Comment.nvim", -- code comments
	"JoosepAlviste/nvim-ts-context-commentstring", --contextual comments

	-- projects / git repos
	"ahmedkhalf/project.nvim", -- project management
	"lewis6991/gitsigns.nvim", -- git signs
	{
		"tpope/vim-fugitive", -- git wrapper
		dependencies = {
			"tpope/vim-rhubarb", -- github urls
			"shumphrey/fugitive-gitlab.vim", -- gitlab urls
			"tommcdo/vim-fubitive", -- bitbucket urls
		},
	},

	-- search and navigation
	{
		"nvim-telescope/telescope.nvim", -- fuzzy finder
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
	},
	{
		"nvim-telescope/telescope-fzf-native.nvim", -- fzf for telescope
		build = "make",
	},
	"moll/vim-bbye", -- delete buffers
	{
		"kyazdani42/nvim-tree.lua", -- file explorer
		dependencies = {
			"kyazdani42/nvim-web-devicons", -- file icons
		},
	},
	"unblevable/quick-scope", -- fast character finding
	{
		"alexghergh/nvim-tmux-navigation", -- navigate between vim and tmux
		config = function()
			local tmux = require("nvim-tmux-navigation")

			tmux.setup({
				disable_when_zoomed = true,
			})
		end,
	},

	-- tree-sitter
	"nvim-treesitter/nvim-treesitter", -- tree-sitter support

	-- refactoring
	{
		"ThePrimeagen/refactoring.nvim",
		dependencies = {
			{ "nvim-lua/plenary.nvim" },
			{ "nvim-treesitter/nvim-treesitter" },
			{ "windwp/nvim-ts-autotag" },
		},
	},
	{
		"filipdutescu/renamer.nvim",
		dependencies = {
			{ "nvim-lua/plenary.nvim" },
		},
	},

	-- wiki
	"vimwiki/vimwiki",

	-- user interface
	{
		"nvim-lualine/lualine.nvim", -- status line
		dependencies = {
			"kyazdani42/nvim-web-devicons", -- file icons
		},
	},
	"akinsho/bufferline.nvim", -- nicer buffer/tab line
	"akinsho/toggleterm.nvim", -- use terminals in editor
	"lukas-reineke/indent-blankline.nvim", -- indent guides
	"goolord/alpha-nvim", -- start page

	-- code completion
	"hrsh7th/nvim-cmp", -- code completion
	"hrsh7th/cmp-buffer", -- buffer completion
	"hrsh7th/cmp-path", -- path completion
	"saadparwaiz1/cmp_luasnip", -- snippet completion
	"hrsh7th/cmp-nvim-lsp", -- lsp support
	"hrsh7th/cmp-nvim-lua", -- lua support
	"windwp/nvim-autopairs", -- autopairs

	-- wriing
	"ellisonleao/glow.nvim", -- markdown preview
	"preservim/vim-markdown", -- markdown syntax highlighting and rules

	-- code snippets
	"L3MON4D3/LuaSnip", -- snippet engine
	"rafamadriz/friendly-snippets", -- preconfigured snippet library

	-- lsp and diagnostics
	"neovim/nvim-lspconfig", -- enables lsp
	{
		"williamboman/mason-lspconfig.nvim", -- lsp installer
		dependencies = {
			"williamboman/mason.nvim",
		},
	},
	"jose-elias-alvarez/null-ls.nvim", -- linting and formatting
	"RRethy/vim-illuminate", -- highlights uses of word under cursor
	{
		"folke/trouble.nvim", -- diagnostics list
		dependencies = {
			"kyazdani42/nvim-web-devicons", -- file icons
		},
	},

	-- debugging
	"mfussenegger/nvim-dap", -- debug adapter protocol client
	"rcarriga/nvim-dap-ui", -- dap ui
	"ravenxrz/DAPInstall.nvim", -- debugger management

	-- database client
	{
		"kndndrj/nvim-dbee", -- db ui
		version = "v0.1.2", -- TODO: Remove once v0.1.4 is out
		dependencies = {
			"MunifTanjim/nui.nvim",
		},
		build = function()
			require("dbee").install()
		end,
	},
}

lazy.setup(plugins, opts)
