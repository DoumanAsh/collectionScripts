-- Based on https://github.com/LunarVim/bigfile.nvim/tree/main

local MIN_FILI_SIZE_MB = 2
local AUGROUP = vim.api.nvim_create_augroup("bigfile", {})

local function disable_heavy_features(buf)
    vim.opt_local.swapfile = false
    vim.opt_local.wrap = false

    -- Disable all auto cmd on write to avoid potentially processing enormous file
    vim.cmd "noautocmd write"

    -- Undo? More like LAG
    vim.opt_local.undolevels = -1
    vim.opt_local.undoreload = 0
    vim.opt_local.hlsearch= false

    -- Big improvement with syntax highlighting on
    vim.opt_local.foldmethod = "manual"
    -- Should be turned off in serious cases, but not critical with fold adjustment
    vim.cmd ":syntax clear"
    vim.opt_local.syntax = "OFF"

    -- filetype turn off
    vim.cmd ":filetype off"

    -- Disable autocomplete since nvim-cmp is garbage on big files
    local cmp = require('cmp')
    cmp.setup {
        enabled = false
    }

    -- You're most likely editing something weird rather than legit code so do not allow lsp
    vim.api.nvim_create_autocmd({ "LspAttach" }, {
      buffer = buf,
      callback = function(args)
        vim.schedule(function()
          vim.lsp.buf_detach_client(buf, args.data.client_id)
        end)
      end,
    })
end

---@param bufnr number
---@return integer|nil size in MiB if buffer is valid, nil otherwise
local function get_buf_size(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local ok, stats = pcall(function()
    return vim.uv.fs_stat(vim.api.nvim_buf_get_name(bufnr))
  end)
  if not (ok and stats) then
    return
  end
  return math.floor(0.5 + (stats.size / (1024 * 1024)))
end

---@param bufnr number
local function on_bufread_pre(bufnr)
  local status_ok, _ = pcall(vim.api.nvim_buf_get_var, bufnr, "bigfile_detected")
  if status_ok then
    return -- buffer has already been processed
  end

  local filesize = get_buf_size(bufnr) or 0
  local bigfile_detected = filesize >= MIN_FILI_SIZE_MB

  if not bigfile_detected then
    vim.api.nvim_buf_set_var(bufnr, "bigfile_detected", 0)
    return
  end

  vim.api.nvim_buf_set_var(bufnr, "bigfile_detected", 1)

  -- Schedule disabling deferred features
  vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    callback = function()
        disable_heavy_features(bufnr)
    end,
    buffer = bufnr,
  })
end

vim.api.nvim_create_autocmd("BufReadPre", {
  group = AUGROUP,
  callback = function(args)
    on_bufread_pre(args.buf)
  end,
})
