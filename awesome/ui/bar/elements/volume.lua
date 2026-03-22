local awful     = require("awful")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local helpers   = require("base.helpers")

local icon      = wibox.widget({
    widget = wibox.widget.textbox,
    font   = beautiful.font_icon .. " " .. beautiful.fs_md,
    markup = helpers.colorizeText(beautiful.icon_vol_mute, beautiful.vol_mute_fg),
    align  = "center",
    valign = "center",
})

local bar       = wibox.widget({
    widget           = wibox.widget.progressbar,
    forced_width     = beautiful.vol_bar_width,
    forced_height    = beautiful.vol_bar_height,
    shape            = helpers.rrect(2),
    bar_shape        = helpers.rrect(2),
    background_color = beautiful.bg_border,
    color            = beautiful.vol_bar_fg,
    value            = 0,
    max_value        = 1,
})

local pct       = wibox.widget({
    widget = wibox.widget.textbox,
    font   = beautiful.font_mono .. " " .. beautiful.fs_xs,
    markup = helpers.colorizeText("0%", beautiful.text_dim),
    align  = "left",
    valign = "center",
})

local widget    = wibox.widget({
    icon,
    helpers.pad(bar, 12, 12, 0, 0),
    pct,
    layout  = wibox.layout.fixed.horizontal,
    spacing = 10,
})

local function update(volume, muted)
    if muted or volume == 0 then
        icon.markup = helpers.colorizeText(beautiful.icon_vol_mute, beautiful.vol_mute_fg)
        bar.color   = beautiful.vol_mute_fg
        pct.markup  = helpers.colorizeText("0%", beautiful.text_dim)
    elseif volume < 50 then
        icon.markup = helpers.colorizeText(beautiful.icon_vol_low, beautiful.vol_low_fg)
        bar.color   = beautiful.vol_low_fg
        pct.markup  = helpers.colorizeText(volume .. "%", beautiful.text_muted)
    else
        icon.markup = helpers.colorizeText(beautiful.icon_vol_high, beautiful.vol_bar_fg)
        bar.color   = beautiful.vol_bar_fg
        pct.markup  = helpers.colorizeText(volume .. "%", beautiful.text_muted)
    end
    bar.value = volume / 100
end

local function fetch()
    awful.spawn.easy_async_with_shell(
        "pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\\d+(?=%)' | head -1 ; pactl get-sink-mute @DEFAULT_SINK@ | grep -oP '(yes|no)'",
        function(stdout)
            local lines = {}
            for line in stdout:gmatch("[^\n]+") do
                table.insert(lines, line)
            end
            local volume = tonumber(lines[1]) or 0
            local muted  = lines[2] == "yes"
            update(volume, muted)
        end
    )
end

fetch()

awful.spawn.with_line_callback("pactl subscribe", {
    stdout = function(line)
        if line:match("sink") then
            fetch()
        end
    end,
})

helpers.onClick(widget, 1, function()
    awful.spawn.easy_async_with_shell("pactl set-sink-mute @DEFAULT_SINK@ toggle")
end)

helpers.hoverCursor(widget)

return widget
