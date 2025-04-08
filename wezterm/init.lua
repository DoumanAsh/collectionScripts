local wezterm = require 'wezterm'
local mux = wezterm.mux

-- Maximize window on start
wezterm.on('gui-attached', function(domain)
  -- maximize all displayed windows on startup
  local workspace = mux.get_active_workspace()
  for _, window in ipairs(mux.all_windows()) do
    if window:get_workspace() == workspace then
      window:gui_window():maximize()
    end
  end
end)

-- This function returns the suggested title for a tab.
-- It prefers the title that was set via `tab:set_title()`
-- or `wezterm cli set-tab-title`, but falls back to the
-- title of the active pane in that tab.
local function tab_title(tab_info)
  local title = tab_info.tab_title
  -- if the tab title is explicitly set, take that
  if title and #title > 0 then
    return title
  end
  -- Otherwise, use the title from the active pane
  -- in that tab
  return tab_info.active_pane.title
end

local function get_max_cols(window)
  local tab = window:active_tab()
  local cols = tab:get_size().cols
  return cols
end

wezterm.on(
  'window-config-reloaded',
  function(window)
    wezterm.GLOBAL.cols = get_max_cols(window)
  end
)

wezterm.on(
  'window-resized',
  function(window, pane)
    wezterm.GLOBAL.cols = get_max_cols(window)
  end
)

wezterm.on(
  'format-tab-title',
  function(tab, tabs, panes, config, hover, max_width)
    local title = tab_title(tab)
    title = wezterm.truncate_left(title, max_width - 2)

    local pad_length = (wezterm.GLOBAL.cols / #tabs - #title) / 2
    if pad_length * 2 + #title > max_width then
        pad_length = (max_width - #title) / 2
    end

    return {
      { Text = string.rep(' ', pad_length) .. title .. string.rep(' ', pad_length) },
    }
  end
)

local config = wezterm.config_builder()

if config.front_end ~= "Software" then
    config.animation_fps = 30
end

config.hide_tab_bar_if_only_one_tab = true
config.font_size = 14.0
config.color_scheme = 'One Half Black (Gogh)'
config.tab_max_width = 9999
config.window_frame = {
  -- The size of the font in the tab bar.
  -- Default to 10.0 on Windows but 12.0 on other systems
  font_size = 16.0,
}
return config
