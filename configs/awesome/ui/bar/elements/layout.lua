local awful      = require("awful")
local wibox      = require("wibox")
local beautiful  = require("beautiful")
local helpers    = require("base.helpers")

local icon       = wibox.widget({
    widget = wibox.widget.textbox,
    font   = beautiful.font_icon .. " " .. beautiful.fs_sm,
    markup = helpers.colorizeText(beautiful.icon_layout_dwindle, beautiful.layout_fg),
    align  = "center",
    valign = "center",
})

local layout_map = {
    dwindle  = beautiful.icon_layout_dwindle,
    floating = beautiful.icon_layout_float,
}

local function update()
    local s = awful.screen.focused()
    if not s or not s.selected_tag then return end
    local name  = awful.layout.get(s).name
    local ico   = layout_map[name] or beautiful.icon_layout_dwindle
    icon.markup = helpers.colorizeText(ico, beautiful.layout_fg)
end

tag.connect_signal("property::layout", function(t)
    if t.screen == awful.screen.focused() then update() end
end)
tag.connect_signal("property::selected", function(t)
    if t.selected then update() end
end)

update()

helpers.onClick(icon, 1, function()
    awful.layout.inc(1)
end)
helpers.hoverCursor(icon)

return icon
