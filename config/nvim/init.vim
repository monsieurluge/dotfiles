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

set cursorline
set number
set wildmode=longest,list
set cc=80 
set ru " display rulers

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
call plug#end()

" theme ----------

colorscheme nord

