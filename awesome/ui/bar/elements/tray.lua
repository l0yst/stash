local wibox      = require("wibox")
local beautiful  = require("beautiful")
local helpers    = require("base.helpers")
local awful      = require("awful")

local icon       = wibox.widget({
    widget = wibox.widget.textbox,
    font   = beautiful.font_icon .. " " .. beautiful.fs_md,
    markup = helpers.colorizeText(beautiful.icon_tray, beautiful.tray_fg),
    align  = "center",
    valign = "center",
})

local tray_popup = wibox({
    visible      = false,
    ontop        = true,
    type         = "popup_menu",
    bg           = beautiful.bg_raised,
    border_color = beautiful.bg_border,
    border_width = beautiful.bar_border_width,
    shape        = helpers.rrect(beautiful.widget_radius),
    width        = 200,
    height       = 40,
})

tray_popup:setup({
    {
        wibox.widget.systray(),
        top = 10,
        bottom = 10,
        left = 12,
        right = 12,
        widget = wibox.container.margin,
    },
    layout = wibox.layout.fixed.horizontal,
})

helpers.onClick(icon, 1, function()
    if tray_popup.visible then
        tray_popup.visible = false
        return
    end
    local s            = awful.screen.focused()
    local bar_geo      = s.bar:geometry()
    tray_popup.x       = bar_geo.x + bar_geo.width - tray_popup.width - 0
    tray_popup.y       = bar_geo.y + beautiful.bar_height + 12
    tray_popup.screen  = s
    tray_popup.visible = true
end)

tray_popup:connect_signal("mouse::leave", function()
    tray_popup.visible = false
end)

helpers.hoverCursor(icon)

return icon
