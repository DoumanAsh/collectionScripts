local au_group = vim.api.nvim_create_augroup("gui", {})
local min_font_size = 8
local font_size = 12
local font = 'Cascadia Code NF'

if vim.g.neovide then
    vim.g.neovide_position_animation_length = 0
    vim.g.neovide_cursor_animation_length = 0.00
    vim.g.neovide_cursor_trail_size = 0
    vim.g.neovide_cursor_animate_in_insert_mode = false
    vim.g.neovide_cursor_animate_command_line = false
    vim.g.neovide_scroll_animation_far_lines = 0
    vim.g.neovide_scroll_animation_length = 0.00
    vim.g.neovide_opacity = 0.90
end

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
