local wibox     = require("wibox")
local beautiful = require("beautiful")
local helpers   = require("base.helpers")
local gears     = require("gears")

local widget    = wibox.widget({
	widget = wibox.widget.textbox,
	font   = beautiful.font_mono .. " Medium " .. beautiful.fs_sm,
	align  = "center",
	valign = "center",
})

local function update()
	widget.markup = helpers.colorizeText(os.date("%I:%M"), beautiful.clock_fg)
end

local function start_timer()
	local secs = 60 - tonumber(os.date("%S"))
	gears.timer.start_new(secs, function()
		update()
		gears.timer({
			timeout   = 60,
			autostart = true,
			callback  = update,
		})
		return false
	end)
end

update()
start_timer()

return widget
