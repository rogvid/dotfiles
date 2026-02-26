local wezterm = require("wezterm")

wezterm.on("user-var-changed", function(window, pane, name, value)
	local overrides = window:get_config_overrides() or {}
	if name == "ZEN_MODE" then
		local incremental = value:find("+")
		local number_value = tonumber(value)
		if incremental ~= nil then
			while number_value > 0 do
				window:perform_action(wezterm.action.IncreaseFontSize, pane)
				number_value = number_value - 1
			end
			overrides.enable_tab_bar = false
		elseif number_value < 0 then
			window:perform_action(wezterm.action.ResetFontSize, pane)
			overrides.font_size = nil
			overrides.enable_tab_bar = true
		else
			overrides.font_size = number_value
			overrides.enable_tab_bar = false
		end
	end
	window:set_config_overrides(overrides)
end)

local config = wezterm.config_builder()

-- color_scheme = 'termnial.sexy',
config.color_scheme = "Catppuccin Mocha"
config.enable_tab_bar = false
config.font_size = 12.0
local is_wsl = os.getenv("WSL_DISTRO_NAME") ~= nil
config.window_decorations = is_wsl and "RESIZE" or "NONE"
-- macos_window_background_blur = 40,
-- macos_window_background_blur = 30,

-- window_background_image = '/Users/omerhamerman/Downloads/3840x1080-Wallpaper-041.jpg',
config.window_background_opacity = 1.00
-- config.window_decorations = "RESIZE"
config.exit_behavior = "Close"
-- keys = {
--   {
--     key = 'f',
--     mods = 'CTRL',
--     action = wezterm.action.ToggleFullScreen,
--   },
-- },
config.mouse_bindings = {
	-- Ctrl-click will open the link under the mouse cursor
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = wezterm.action.OpenLinkAtMouseCursor,
	},
}

return config
