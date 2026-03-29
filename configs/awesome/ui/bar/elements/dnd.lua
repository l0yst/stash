local wibox     = require("wibox")
local beautiful = require("beautiful")
local helpers   = require("base.helpers")
local naughty   = require("naughty")

local dnd       = false

local icon      = wibox.widget({
    widget = wibox.widget.textbox,
    font   = beautiful.font_icon .. " " .. beautiful.fs_sm,
    markup = helpers.colorizeText(beautiful.icon_dnd, beautiful.terracotta),
    align  = "center",
    valign = "center",
})

local function refresh()
    local color = dnd and beautiful.notif_fg or beautiful.terracotta
    icon.markup = helpers.colorizeText(beautiful.icon_dnd, color)
end

helpers.onClick(icon, 1, function()
    dnd = not dnd
    if dnd then
        naughty.suspend()
    else
        naughty.resume()
    end
    refresh()
end)

helpers.hoverCursor(icon)

return icon
