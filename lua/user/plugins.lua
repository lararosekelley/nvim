local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
	PACKER_BOOTSTRAP = vim.fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})

	print("installing packer... close and re-open neovim")

	vim.cmd([[packadd packer.nvim]])
end

-- reload neovim when this plugins file is updated
vim.cmd([[
  augroup ReloadPlugins
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

-- don't error on first use of packer
local status_ok, packer = pcall(require, "packer")
if not status_ok then
	return
end

-- use pop-up window with packer
packer.init({
	display = {
		open_fn = function()
			return require("packer.util").float({ border = "rounded" })
		end,
	},
})

-- plugin list
return packer.startup(function(use)
	-- packer
	use("wbthomason/packer.nvim")

	-- neovim
	use("nvim-lua/plenary.nvim") -- neovim functions
	use("lewis6991/impatient.nvim") -- faster startup time
	use("tpope/vim-eunuch") -- unix commands in vim

	-- comments
	use("numToStr/Comment.nvim") -- code comments
	use("JoosepAlviste/nvim-ts-context-commentstring") -- contextual commentstring

	-- projects and git repos
	use("ahmedkhalf/project.nvim") -- project management
	use("lewis6991/gitsigns.nvim") -- git signs
	use({
		"tpope/vim-fugitive",
		requires = {
			"tpope/vim-rhubarb",
			"tpope/fugitive-gitlab.vim",
		},
	})

	-- search and navigation
	use({
		"nvim-telescope/telescope.nvim", -- fuzzy finder
		requires = {
			"nvim-lua/plenary.nvim",
		},
	})
	use({
		"nvim-telescope/telescope-fzf-native.nvim", -- fzf for telescope
		run = "make",
	})
	use("moll/vim-bbye") -- delete buffers
	use({
		"kyazdani42/nvim-tree.lua", -- file explorer
		requires = {
			"kyazdani42/nvim-web-devicons", -- file icons
		},
	})
	use("unblevable/quick-scope") -- fast character finding

	use({
		"alexghergh/nvim-tmux-navigation", -- navigate between vim and tmux
		config = function()
			local tmux = require("nvim-tmux-navigation")

			tmux.setup({
				disable_when_zoomed = true,
			})
		end,
	})

	-- tree-sitter
	use("nvim-treesitter/nvim-treesitter") -- tree-sitter support

	-- wiki
	use("vimwiki/vimwiki")

	-- user interface
	use("rafi/awesome-vim-colorschemes") -- color schemes
	use({ -- status line
		"nvim-lualine/lualine.nvim",
		requires = {
			"kyazdani42/nvim-web-devicons", -- file icons
		},
	})
	use("akinsho/bufferline.nvim") -- nicer buffer/tab line
	use("akinsho/toggleterm.nvim") -- use terminals in editor
	use("lukas-reineke/indent-blankline.nvim") -- indent guides
	use("goolord/alpha-nvim") -- start page

	-- code completion
	use("hrsh7th/nvim-cmp") -- code completion
	use("hrsh7th/cmp-buffer") -- buffer completion
	use("hrsh7th/cmp-path") -- path completion
	use("saadparwaiz1/cmp_luasnip") -- snippet completion
	use("hrsh7th/cmp-nvim-lsp") -- lsp support
	use("hrsh7th/cmp-nvim-lua") -- lua support
	use("windwp/nvim-autopairs") -- autopairs

	-- wriing
	use("ellisonleao/glow.nvim")

	-- code snippets
	use("L3MON4D3/LuaSnip") -- snippet engine
	use("rafamadriz/friendly-snippets") -- preconfigured snippet library

	-- lsp and diagnostics
	use("williamboman/nvim-lsp-installer") -- language server installer
	use("neovim/nvim-lspconfig") -- enables lsp
	use("jose-elias-alvarez/null-ls.nvim") -- linting and formatting
	use("RRethy/vim-illuminate") -- highlights uses of word under cursor
	use({
		"folke/trouble.nvim", -- diagnostics list
		requires = {
			"kyazdani42/nvim-web-devicons", -- file icons
		},
	})

	-- debugging
	use("mfussenegger/nvim-dap") -- debug adapter protocol client
	use("rcarriga/nvim-dap-ui") -- dap ui
	use("ravenxrz/DAPInstall.nvim") -- debugger management

	-- sets up my configuration after packer.nvim is cloned; leave at end of function
	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)
