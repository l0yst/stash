local awful = require("awful")
local beautiful = require("beautiful")
local helpers = require("base.helpers")

local widget = helpers.text({
	text = beautiful.icon_launcher,
	font = beautiful.font_icon,
	size = beautiful.fs_sm,
	fg = beautiful.sky,

	pad_top = -1,
	pad_bottom = 0,
	pad_left = 10,
	pad_right = 10,

	bg = beautiful.bg_overlay,
	radius = beautiful.widget_radius,
	border_width = beautiful.bar_border_width,
	border_color = beautiful.bg_border,

	align = "center",
	valign = "center",
})

widget:connect_signal("mouse::enter", function()
	widget.border_color = beautiful.sky
end)

widget:connect_signal("mouse::leave", function()
	widget.border_color = beautiful.bg_border
end)

helpers.onClick(widget, 1, function()
	awful.spawn.with_shell("rofi -show drun -theme " .. os.getenv("HOME") .. "/.config/rofi/layout/apps.rasi")
end)

return widget
