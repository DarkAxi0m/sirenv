local wezterm = require 'wezterm'
local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.font = wezterm.font("FiraCode Nerd Font Mono", {weight="Regular", stretch="Normal", style="Normal"}) -- /home/chris/.fonts/Fira Code Regular Nerd Font Complete Mono.ttf, FontConfig
config.font_size = 10
config.color_scheme = 'Nightfly'
config.window_background_opacity = 0.9

return config
