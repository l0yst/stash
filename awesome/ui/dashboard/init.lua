local awful     = require("awful")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local helpers   = require("base.helpers")
local content   = require("ui.dashboard.widgets")
local system    = require("ui.dashboard.widgets.system")
local playerctl = require("ui.dashboard.widgets.playerctl")

local dashboard = {}

local popup     = wibox({
    visible      = false,
    ontop        = true,
    type         = "popup_menu",
    bg           = beautiful.dashboard_bg,
    border_color = beautiful.bg_border,
    border_width = beautiful.bar_border_width,
    shape        = helpers.rrect(beautiful.dashboard_radius),
    width        = beautiful.dashboard_width,
    height       = beautiful.dashboard_height,
})

popup:setup({
    content,
    layout = wibox.layout.fixed.vertical,
})

local close_overlay = wibox({
    x       = 0,
    y       = 0,
    width   = 1,
    height  = 1,
    opacity = 0,
    ontop   = true,
    type    = "desktop",
    visible = false,
})

local function hide()
    popup.visible         = false
    close_overlay.visible = false
    system.stop()
    playerctl.stop()
end

close_overlay:buttons(awful.util.table.join(
    awful.button({}, 1, hide),
    awful.button({}, 3, hide)
))

local function show()
    local s               = awful.screen.focused()
    local geo             = s.bar:geometry()
    popup.screen          = s
    popup.x               = geo.x + geo.width - popup.width - beautiful.dashboard_x
    popup.y               = geo.y + beautiful.bar_height + beautiful.dashboard_y

    close_overlay.screen  = s
    close_overlay.x       = s.geometry.x
    close_overlay.y       = s.geometry.y
    close_overlay.width   = s.geometry.width
    close_overlay.height  = s.geometry.height
    close_overlay.visible = true

    content.refresh()
    popup.visible = true
    popup:raise()
end

function dashboard.toggle()
    if popup.visible then hide() else show() end
end

return dashboard
