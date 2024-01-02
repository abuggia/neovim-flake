let mapleader = " "
nnoremap <leader>s :w<cr>
nnoremap <leader>q :q<cr>
noremap <leader>e :Ex<cr>
nnoremap <C-p> :MarkdownPreview<cr>

" navigate by displayed line vs physical line
noremap <silent> k gk
noremap <silent> j gj
noremap <silent> 0 g0
noremap <silent> $ g$

set linebreak
set noerrorbells
set nohlsearch
set autoread 
set nohlsearch
set incsearch
set termguicolors
set scrolloff=5
set updatetime=300
set expandtab
set tabstop=2
set shiftwidth=2
set clipboard+=unnamedplus
set signcolumn=yes
set ignorecase

autocmd vimenter * ++nested colorscheme catppuccin

:lua require('init')
