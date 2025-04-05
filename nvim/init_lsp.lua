local status, cmp = pcall(require, 'cmp')

local function is_cmp_visible()
    return cmp.visible()
end

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
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
  buf_set_keymap('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  buf_set_keymap('n', 'gL', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
end

-- If cannot import cmp, then most likely deps are not installed
if status then

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
    single_file_support = true,
    settings = {
        python = {
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
        }
    }
}
-- Rust LSP
lspconfig.rust_analyzer.setup {
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
        ["rust-analyzer"] = {
            diagnostics = {
                enable = true,
                refreshSupport = false,
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

--- Zig LSP
lspconfig.zls.setup {
  -- There are two ways to set config options:
  --   - edit your `zls.json` that applies to any editor that uses ZLS
  --   - set in-editor config options with the `settings` field below.
  --
  -- Further information on how to configure ZLS:
  -- https://zigtools.org/zls/configure/
  settings = {
    zls = {
    }
  }
}

---General TS
require("typescript-tools").setup {
  on_attach = on_attach,
  ---Do not run by default to avoid errors in projects without typescript server
  autostart = false,
  settings = {
    -- spawn additional tsserver instance to calculate diagnostics on it
    separate_diagnostic_server = true,
    -- "change"|"insert_leave" determine when the client asks the server about diagnostic
    publish_diagnostic_on = "insert_leave",
    -- array of strings("fix_all"|"add_missing_imports"|"remove_unused"|
    -- "remove_unused_imports"|"organize_imports") -- or string "all"
    -- to include all supported code actions
    -- specify commands exposed as code_actions
    expose_as_code_action = {},
    -- string|nil - specify a custom path to `tsserver.js` file, if this is nil or file under path
    -- not exists then standard path resolution strategy is applied
    tsserver_path = nil,
    -- specify a list of plugins to load by tsserver, e.g., for support `styled-components`
    -- (see 💅 `styled-components` support section)
    tsserver_plugins = {},
    -- this value is passed to: https://nodejs.org/api/cli.html#--max-old-space-sizesize-in-megabytes
    -- memory limit in megabytes or "auto"(basically no limit)
    tsserver_max_memory = "auto",
    -- described below
    tsserver_format_options = {},
    tsserver_file_preferences = {},
    -- locale of all tsserver messages, supported locales you can find here:
    -- https://github.com/microsoft/TypeScript/blob/3c221fc086be52b19801f6e8d82596d04607ede6/src/compiler/utilitiesPublic.ts#L620
    tsserver_locale = "en",
    -- mirror of VSCode's `typescript.suggest.completeFunctionCalls`
    complete_function_calls = false,
    include_completions_with_insert_text = true,
    -- CodeLens
    -- WARNING: Experimental feature also in VSCode, because it might hit performance of server.
    -- possible values: ("off"|"all"|"implementations_only"|"references_only")
    code_lens = "off",
    -- by default code lenses are displayed on all referencable values and for some of you it can
    -- be too much this option reduce count of them by removing member references from lenses
    disable_member_code_lens = true,
    -- JSXCloseTag
    -- WARNING: it is disabled by default (maybe you configuration or distro already uses nvim-ts-autotag,
    -- that maybe have a conflict if enable this feature. )
    jsx_close_tag = {
        enable = false,
        filetypes = { "javascriptreact", "typescriptreact" },
    }
  },
}

---Deno/TS
lspconfig.denols.setup {
  on_attach = on_attach,
  root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
  single_file_support = false,
}

---nushell
lspconfig.nushell.setup {
    cmd = { 'nu', '--lsp' },
    filetypes = { 'nu' },
    root_dir = function(fname)
      return vim.fs.dirname(vim.fs.find('.git', { path = fname, upward = true })[1])
    end,
    single_file_support = true,
}

---Yaml
--- Install node with npm and then:
--- npm install -g yaml-language-server
lspconfig.yamlls.setup {
  on_attach = on_attach,
  single_file_support = true,
  silent = true,
  settings = {
      yaml = {
          format = {
              enable = false
          },
          schemas = {
              ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
              ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "compose.y*ml",
          },
      },
      redhat = {
          telemetry = {
              enabled = false
          }
      },
  },
}

---Lua
-- Refer to https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#lua_ls
lspconfig.lua_ls.setup {
  on_attach = on_attach,
  silent = true,
  single_file_support = true,
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if path ~= vim.fn.stdpath('config') and (vim.loop.fs_stat(path..'/.luarc.json') or vim.loop.fs_stat(path..'/.luarc.jsonc')) then
        return
      end
    end

    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
      runtime = {
        -- Tell the language server which version of Lua you're using
        -- (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT'
      },
      -- Make the server aware of Neovim runtime files
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME
          -- Depending on the usage, you might want to add additional paths here.
          -- "${3rd}/luv/library"
          -- "${3rd}/busted/library",
        }
      }
    })
  end,
  settings = {
    Lua = {}
  }
}

---TOML validation
--- Install from https://github.com/tamasfe/taplo/releases/latest (go for FULL version)
lspconfig.taplo.setup {
  on_attach = on_attach,
  single_file_support = true,
  silent = true,
  settings = {
      eventBetterToml = {
          schema = {
              enabled = true,
              catalogs = {
                  -- This index is much smaller than default one and contains all you need for Rust
                  "https://taplo.tamasfe.dev/schema_index.json"
              }
          }
      }
  }
}

---Terraform LSP
lspconfig.terraformls.setup {
  on_attach = on_attach,
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
  sources = cmp.config.sources({
    { name = 'path' },
  }, {
    { name = 'cmdline' },
  }),
})

-- Function to check if a floating dialog exists and if not
-- then check for diagnostics under the cursor
function OpenDiagnosticIfNoFloat()
  for _, winid in pairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_config(winid).zindex then
      return
    end
  end
  -- Nothing is opened, show diagnostic window
  vim.diagnostic.open_float(0, {
    scope = "cursor",
    focusable = false,
    close_events = {
      "CursorMoved",
      "CursorMovedI",
      "BufHidden",
      "InsertCharPre",
      "WinLeave",
    },
  })
end

-- Show diagnostics under the cursor when holding position
vim.o.updatetime = 750
vim.api.nvim_create_augroup("lsp_diagnostics_hold", { clear = true })
vim.api.nvim_create_autocmd({ "CursorHold" }, {
  pattern = "*",
  command = "lua OpenDiagnosticIfNoFloat()",
  group = "lsp_diagnostics_hold",
})

--- Adjust defaults to disable virtual text as it is pure garbage without ability to wrap
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
      virtual_text = false,
      signs = true,
      update_in_insert = false,
      underline = true,
    }
)

end
