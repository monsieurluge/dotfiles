set nocompatible

" general ----------

set hlsearch
set shell=zsh
set ttyfast
set ignorecase " ignore case when searching

" formatting ----------

syntax on
set tabstop=4
set softtabstop=4
set expandtab
set shiftwidth=4
set autoindent
set si " smart indent
set nowrap
scriptencoding utf-8
set encoding=utf-8

" ui ----------

set number
set wildmode=longest,list
set cc=80 
set ru " display rulers
set cursorline
highlight Visual cterm=none ctermbg=236 ctermfg=none guibg=Grey40
highlight LineNr cterm=none ctermfg=240 guifg=#2b506e guibg=#000000

" system ----------

set mouse=a
set clipboard+=unnamedplus

" mappings ----------

nnoremap ; l
nnoremap l k
nnoremap k j
nnoremap j h

" plugins ----------

call plug#begin()
  Plug 'shaunsingh/nord.nvim'
  Plug 'scrooloose/nerdtree'
  Plug 'nvim-treesitter/nvim-treesitter'
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim'
call plug#end()

" theme ----------

colorscheme nord

