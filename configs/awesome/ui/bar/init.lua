local awful     = require("awful")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local helpers   = require("base.helpers")
local launcher  = require("ui.bar.elements.launcher")
local tags      = require("ui.bar.elements.tags")
local separator = require("ui.bar.elements.separator")
local wifi      = require("ui.bar.elements.wifi")
local volume    = require("ui.bar.elements.volume")
local pill      = require("ui.bar.elements.pill")
local time      = require("ui.bar.elements.time")
local dashboard = require("ui.dashboard")

local M         = {}

local pfp       = wibox.widget({
    widget     = wibox.widget.imagebox,
    image      = beautiful.pfp,
    resize     = true,
    clip_shape = helpers.rrect(999),
    valign     = "center",
    halign     = "center"
})

helpers.onClick(pfp, 1, function()
    dashboard.toggle()
end)
helpers.hoverCursor(pfp)

function M.setup(s)
    local screen_width = s.geometry.width
    local bar_width    = math.floor(screen_width * beautiful.bar_ratio)

    s.bar              = awful.wibar({
        screen       = s,
        position     = "top",
        stretch      = false,
        width        = bar_width,
        height       = beautiful.bar_height,
        align        = "centered",
        bg           = beautiful.bg_raised,
        border_color = beautiful.bg_border,
        border_width = beautiful.bar_border_width,
        shape        = helpers.rrect(beautiful.bar_radius),
        margins      = {
            top = beautiful.bar_margin,
        },
    })

    s.bar:setup({
        widget = wibox.container.margin,
        margins = beautiful.widget_padding,
        {
            layout = wibox.layout.align.horizontal,
            {
                layout = wibox.layout.fixed.horizontal,
                spacing = beautiful.widget_spacing,
                launcher,
                separator.new(),
                tags.new(s),
            },
            { layout = wibox.layout.align.horizontal },
            {
                layout = wibox.layout.fixed.horizontal,
                spacing = beautiful.widget_spacing,
                wifi,
                separator.new(),
                volume,
                separator.new(),
                pill,
                separator.new(),
                time,
                separator.new(),
                pfp
            },
        },
    })
end

return M
