"""Script current folder
let s:CWD = expand('<sfile>:p:h')

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Pre-load file checker
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
:execute "source " . expand(s:CWD) . "/big_file.lua"

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""" General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""''
:set hidden
:set nobackup
:set nowritebackup
:set viminfofile=NONE

:set fileformat=unix
:set fileformats=unix,dos
:let g:netrw_dirhistmax = 0
:set noswapfile
:filetype plugin indent on
:set tabstop=4 softtabstop=4 shiftwidth=4 expandtab
:set ignorecase
:set smartcase
:set nu
:map <C-s> :w <Enter>
:inoremap <c-s> <Esc>:update<CR>
:vmap <c-s> <Esc><c-s>gv
:autocmd BufWritePre *.* :%s/\s\+$//e
:set laststatus=2

:syntax on
:set encoding=utf-8
":set termencoding=utf-8
:set fileencoding=utf-8
:set fileencodings=utf8,ucs-bom,sjis,latin1,koi8r,cp932,cp1251,cp866,ucs-2le,default
:set hlsearch

" Under bar command height
:set cursorline
:set synmaxcol=240
" Indent set on tab in normal and visual mode
" Do not remap TAB in normal or you'll need to remap C-I
:nnoremap <C-Tab> >>
:nnoremap <S-Tab> <<
:vnoremap <Tab> >gv
:vnoremap <S-Tab> <gv
" For insert mode let's make only reverse indent
:inoremap <S-Tab> <C-D>
:set spell spelllang=en_us

" Copy to clipboard
:set clipboard+=unnamedplus

" Auto-load rusty tags
autocmd BufRead *.* :setlocal tags=./tags;/

" C++ no namespace ident
:set cino=N-s

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""''
""" Terminal
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""''
" Exit terminal on Esc
:tnoremap <Esc> <C-\><C-n>
:execute "source " . expand(s:CWD) . "/terminal.lua"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""''

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""" Plugins
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""''
call plug#begin('~/.vim/plugged')
"Dependencies
Plug 'nvim-lua/plenary.nvim', {'branch': 'master'}
"Lang specific
Plug 'rust-lang/rust.vim', {'branch': 'master'}
Plug 'navarasu/onedark.nvim'
Plug 'dart-lang/dart-vim-plugin', {'branch': 'master'}
Plug 'ziglang/zig.vim'
Plug 'pmizio/typescript-tools.nvim', {'branch': 'master' }
"LSP
Plug 'neovim/nvim-lspconfig', {'branch': 'master'}
"Auto-complete
Plug 'hrsh7th/nvim-cmp', {'branch': 'main'}
Plug 'hrsh7th/cmp-nvim-lsp', {'branch': 'main'}
Plug 'hrsh7th/cmp-buffer', {'branch': 'main'}
Plug 'hrsh7th/cmp-path', {'branch': 'main'}
Plug 'hrsh7th/cmp-nvim-lsp-signature-help', {'branch': 'main'}
Plug 'uga-rosa/cmp-dictionary', {'branch': 'main'}
Plug 'quangnguyen30192/cmp-nvim-tags', {'branch': 'main'}
"snippets
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'
" Initialize plugin system
" If you add new plugins, be sure to reload and run :PlugInstall
call plug#end()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""" Zig
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""''
" don't show parse errors in a separate window
let g:zig_fmt_parse_errors = 0
" disable format-on-save from `ziglang/zig.vim`
let g:zig_fmt_autosave = 0
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""" Rust
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""''
let g:rustfmt_autosave = 0
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""" Color scheme setup
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""''
let g:onedark_config = {
  \ 'style': 'dark',
  \ 'ending_tildes': v:true,
  \ 'term_colors': v:true,
  \ 'code_style': {
    \ 'comments' : 'italic',
    \ 'keywords' : 'bold',
  \ },
  \ 'diagnostics': {
    \ 'darker': v:true,
    \ 'background': v:false,
  \ },
  \ 'highlights': {
    \ 'PreProc': {
      \ 'fg': '$yellow',
    \ },
  \ },
\ }
:colorscheme onedark

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""" Autocomplete
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""''
:set signcolumn=yes
:set completeopt=longest,menuone,preview,noinsert

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" LSP
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
:execute "source " . expand(s:CWD) . "/init_lsp.lua"

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""" Status line
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""''
:set statusline=%f%m%r%h%w\ %y\ enc:%{&enc}\ ff:%{&ff}\ fenc:%{&fenc}%=(ch:%3b\ hex:%2B)\ col:%2c\ line:%2l/%L\ [%2p%%]

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""" Commands
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""''
:command Vimrc exe 'edit '.stdpath('config').'/init.vim'
:command SysVimrc exe 'edit $VIM/sysinit.vim'
"use this command for when you need to write in russian.
:command RuMode set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""" UI
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""''
"Setup mouse
:set mouse=nvc
"Scroll code with  mouse
:map <ScrollWheelUp> <C-Y>
:map <S-ScrollWheelUp> <C-U>
:map <ScrollWheelDown> <C-E>
:map <S-ScrollWheelDown> <C-D>

"Setup GUI
if exists("g:GuiLoaded") || exists("g:neovide") || !empty($NVIM_QT)
    :execute "source " . expand(s:CWD) . "/gui.lua"
    if has("linux")
        " Use concrete language locale on Linux
        :language en_US.utf8
    else
        :language en_US
    endif
    "Maximize window as much as possible
    :set lines=999 columns=999
    :let g:neovide_position_animation_length = 0
    :let g:neovide_cursor_animation_length = 0.00
    :let g:neovide_cursor_trail_size = 0
    :let g:neovide_cursor_animate_in_insert_mode = v:false
    :let g:neovide_cursor_animate_command_line = v:false
    :let g:neovide_scroll_animation_far_lines = 0
    :let g:neovide_scroll_animation_length = 0.00
endif

"Run Explore if no files are passed.
if argc() == 0 && !exists("s:std_in")
    autocmd vimenter * Explore $HOME
endif
