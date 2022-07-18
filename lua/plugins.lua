vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use "neovim/nvim-lspconfig"

  -- completion
  use "hrsh7th/nvim-cmp"
  use "hrsh7th/cmp-buffer"
  use "hrsh7th/cmp-path"
  use "hrsh7th/cmp-nvim-lua"
  use "hrsh7th/cmp-nvim-lsp"

  use "saadparwaiz1/cmp_luasnip"
  use "L3MON4D3/LuaSnip"

  use "rafamadriz/friendly-snippets"

  use 'morhetz/gruvbox'
  use 'vim-airline/vim-airline'

  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }
  use {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} }
  }
  use 'dhruvmanila/telescope-bookmarks.nvim'
  use "lukas-reineke/lsp-format.nvim"
end)


