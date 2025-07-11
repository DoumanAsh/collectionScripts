local au_group = vim.api.nvim_create_augroup("gui", {})
local min_font_size = 8
local font_size = 12
local font = 'Consolas'

local function adjust_font_size(amount)
    if vim.o.guifont then
        font_size = font_size + amount
        if font_size >= min_font_size then
            vim.o.guifont = font .. ":h" .. font_size
        else
            font_size = min_font_size
        end
    end
end

vim.api.nvim_create_autocmd("UIEnter", {
  group = au_group,
  callback = function()
      adjust_font_size(0)
  end,
})
vim.keymap.set('n', '<C-ScrollWheelUp>', function() adjust_font_size(1) end, { remap = true, desc = "Increase font size" })
vim.keymap.set('n', '<C-ScrollWheelDown>', function() adjust_font_size(-1) end, { remap = true, desc = "Decrease font size" })
