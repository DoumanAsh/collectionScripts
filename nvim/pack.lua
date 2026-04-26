vim.api.nvim_create_user_command('PackUpdate', "lua vim.pack.update()<CR>", {
    desc = "Update Pack plugins"
})

vim.api.nvim_create_user_command('PackList', "lua vim.pack.update(nil, {offline = true})<CR>", {
    desc = "List Pack plugins"
})

vim.api.nvim_create_user_command('PackClean', "lua vim.iter(vim.pack.get()):filter(function(x) return not x.active end):map(function(x) return x.spec.name end):totable()<CR>", {
    desc = "Clean uninstalled Pack plugins"
})

vim.pack.add({
--Dependencies
    { src = "https://github.com/nvim-lua/plenary.nvim", branch = "master" },
--Theme
    { src = "https://github.com/navarasu/onedark.nvim", branch = "master" },
--Lang specific
    { src = "https://github.com/rust-lang/rust.vim", branch = "master" },
    { src = "https://github.com/dart-lang/dart-vim-plugin", branch = "master" },
    { src = "https://codeberg.org/ziglang/zig.vim", branch = "master" },
    { src = "https://github.com/pmizio/typescript-tools.nvim", branch = "master" },
--LSP
    { src = "https://github.com/neovim/nvim-lspconfig", branch = "master" },
--Auto-complete
    { src = "https://github.com/hrsh7th/nvim-cmp", branch = "main" },
    { src = "https://github.com/hrsh7th/cmp-nvim-lsp", branch = "main" },
    { src = "https://github.com/hrsh7th/cmp-buffer", branch = "main" },
    { src = "https://github.com/hrsh7th/cmp-path", branch = "main" },
    { src = "https://github.com/hrsh7th/cmp-nvim-lsp-signature-help", branch = "main" },
    { src = "https://github.com/uga-rosa/cmp-dictionary", branch = "main" },
    { src = "https://github.com/quangnguyen30192/cmp-nvim-tags", branch = "main" },
--snippets
    { src = "https://github.com/hrsh7th/cmp-vsnip", branch = "main" },
    { src = "https://github.com/hrsh7th/vim-vsnip", branch = "main" },
},
{
    confirm = false,
    load = true,
})
