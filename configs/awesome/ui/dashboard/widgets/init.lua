local wibox     = require("wibox")
local beautiful = require("beautiful")
local helpers   = require("base.helpers")
local header    = require("ui.dashboard.widgets.header")
local system    = require("ui.dashboard.widgets.system")
local controls  = require("ui.dashboard.widgets.controls")
local playerctl = require("ui.dashboard.widgets.playerctl")

local sep       = wibox.widget({
    widget        = wibox.container.background,
    bg            = beautiful.bg_border,
    forced_height = 1,
    forced_width  = 1,
})

local widget    = wibox.widget({
    helpers.box(helpers.pad(header, 25, 25, 30, 30), beautiful.bg_overlay),
    sep,
    {
        helpers.pad(system, 30, 40, 30, 30),
        sep,
        helpers.pad(controls, 30, 40, 30, 30),
        layout = wibox.layout.fixed.horizontal,
    },
    sep,
    helpers.pad(playerctl, 15, 15, 30, 30),
    layout = wibox.layout.fixed.vertical,
})

function widget.refresh()
    header.refresh()
    system.refresh()
    controls.refresh()
    playerctl.refresh()
end

return widget
