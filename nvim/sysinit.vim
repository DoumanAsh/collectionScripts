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
:set termencoding=utf-8
:set fileencoding=utf-8
:set fileencodings=utf8,ucs-bom,sjis,latin1,koi8r,cp932,cp1251,cp866,ucs-2le,default
:set hlsearch

:set cursorline
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

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""" Plugins
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""''
call plug#begin('~/.vim/plugged')
Plug 'rust-lang/rust.vim', {'branch': 'master'}
Plug 'joshdick/onedark.vim', {'branch': 'master'}
Plug 'dart-lang/dart-vim-plugin', {'branch': 'master'}
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

let g:rustfmt_autosave = 0
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
lua <<EOF
-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local cmp = require 'cmp'
function is_cmp_visible()
    local cmp = require 'cmp'
    return cmp.visible()
end

local on_attach = function(client, bufnr)
  local function buf_set_keymap(...)
    vim.api.nvim_buf_set_keymap(bufnr, ...)
  end

  -- Mappings.
  local opts = { noremap = true, silent = true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'gh', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', 'gH', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', 'gR', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', 'gA', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gl', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', 'gL', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
end

-- Hover automatically
-- vim.o.updatetime = 1000
-- vim.cmd [[autocmd! CursorHold,CursorHoldI * lua if not is_cmp_visible() then vim.lsp.buf.hover() end]]

-- Enable some language servers with the additional completion capabilities offered by nvim-cmp
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local lspconfig = require('lspconfig')
-- Dart LSP
lspconfig.dartls.setup {
    capabilities = capabilities,
    on_attach = on_attach,
}
-- C++ LSP
lspconfig.clangd.setup {
    capabilities = capabilities,
    on_attach = on_attach,
    filetypes = { "c", "cpp" },
    single_file_support = true,
    cmd = {
        "clangd",
        "--clang-tidy",                -- enable clang-tidy diagnostics
        "--background-index",          -- index project code in the background and persist index on disk
        "--completion-style=detailed", -- granularity of code completion suggestions: bundled, detailed
    }
}
-- Python LSP
lspconfig.pyright.setup {
    capabilities = capabilities,
    on_attach = on_attach,
}
-- Rust LSP
lspconfig.rust_analyzer.setup {
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
        ["rust-analyzer"] = {
            diagnostics = {
                enable = true,
                disabled = { "inactive-code" }
            },
            imports = {
                merge = {
                    glob = false,
                },
            },
            cachePriming = {
                numThreads = 1,
                enable = false,
            },
            completion = {
                autoimport = {
                    enable = false
                },
            },
            checkOnSave = {
                enable = false
            },
            cargo = {
                buildScripts = {
                    enable = false
                },
            },
        }
    },
}

-- nvim-cmp setup
cmp.setup {
    snippet = {
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      end,
    },
  mapping = cmp.mapping.preset.insert({
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if is_cmp_visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if is_cmp_visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'nvim_lsp_signature_help' },
    { name = 'vsnip' },
    { name = 'tags' },
    { name = 'buffer' },
    { name = 'path', trigger_characters = { '/' } },
    { name = 'dictionary', keyword_length = 3, max_item_count = 5 },
  },
  formatting = {
    format = function(entry, vim_item)
      -- Tag main sources
      vim_item.menu = ({
        nvim_lsp   = '[L]',
        path       = '[P]',
        tags       = '[T]',
        dictionary = '[D]',
        buffer     = '[B]',
      })[entry.source.name] or ''
      -- Clean all duplicates except lsp
      -- Generally if I use LSP, then tags would unused anyway
      vim_item.dup = ({
        nvim_lsp = 1,
      })[entry.source.name] or 0
      return vim_item
    end
  },
}

cmp.setup.cmdline(':', {
  completion = { autocomplete = true },
  sources = cmp.config.sources({
    { name = 'path' },
  }, {
    { name = 'cmdline' },
  }),
})

EOF

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

"Set UI language
:language en_US
"Run Explore if no files are passed.
if argc() == 0 && !exists("s:std_in")
    autocmd vimenter * Explore
endif
"Set font
let s:fontsize = 12
function! AdjustFontSize(amount)
    let s:fontsize = s:fontsize+a:amount
    if exists("g:GuiLoaded")
        :execute "GuiFont! Consolas:h" . s:fontsize
    endif
endfunction

:map <C-ScrollWheelUp> :call AdjustFontSize(1)<Enter>
:map <C-ScrollWheelDown> :call AdjustFontSize(-1)<Enter>
autocmd UIEnter * call  AdjustFontSize(0)
