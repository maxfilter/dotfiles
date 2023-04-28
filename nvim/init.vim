" (Neo)vim config

" Sensible defaults
set backspace=indent,eol,start

" UI
syntax on			" syntax highlighting
set number          " show current line number
set relativenumber  " show relative line numbers
set ruler           " show cursor position
set colorcolumn=80  " add vertical ruler
highlight ColorColumn ctermbg=0  " set ruler color to lightgrey

" Indent & Tab
set autoindent		" use current indent on next line
set shiftwidth=4	" n spaces to use for each step of (auto)indent
set softtabstop=4 	" n spaces that a <Tab> counts for while inserting a <Tab>
set tabstop=4		" n spaces that a <Tab> in the file counts for
set expandtab		" use the appropriate number of spaces to insert a <Tab>
filetype indent on

" Search
set ignorecase      " ignore case in search patterns
set hlsearch        " highlight all search matches
set incsearch       " show incremental search results as you type

" Buffer
set noswapfile 	    " disable swapfile

" Key Map
inoremap jk <ESC>	" remap esc to 'jk'

" Vim-Plug
call plug#begin()

" color schemes
Plug 'folke/tokyonight.nvim', {'branch': 'main'}

" language-specific syntax highlighting
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" fuzzy search
" https://github.com/nvim-telescope/telescope.nvim
" Plug 'nvim-lua/plenary.nvim'
" Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.1' }
call plug#end()

" Load Lua plugin configs
lua require('treesitter')

" Color
colorscheme tokyonight-night

