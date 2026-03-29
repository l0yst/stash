local wibox     = require("wibox")
local beautiful = require("beautiful")
local helpers   = require("base.helpers")

local layout    = require("ui.bar.elements.layout")
local dnd       = require("ui.bar.elements.dnd")
local tray      = require("ui.bar.elements.tray")

local sep       = wibox.widget({
    widget        = wibox.container.background,
    bg            = beautiful.bg_border,
    forced_width  = beautiful.sep_width,
    forced_height = beautiful.sep_height,
})


local widget = wibox.widget({
    {
        {
            layout,
            sep,
            dnd,
            sep,
            tray,
            layout = wibox.layout.fixed.horizontal,
            spacing = 10,
        },
        margins = { top = 0, bottom = 0, left = beautiful.pill_padding, right = beautiful.pill_padding },
        widget = wibox.container.margin,
    },
    bg           = beautiful.bg_overlay,
    shape        = helpers.rrect(beautiful.pill_radius),
    border_width = beautiful.bar_border_width,
    border_color = beautiful.bg_border,
    widget       = wibox.container.background,
})

return widget
