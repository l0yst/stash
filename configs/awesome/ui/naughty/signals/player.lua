local awful        = require("awful")
local naughty      = require("naughty")
local wibox        = require("wibox")
local beautiful    = require("beautiful")
local helpers      = require("base.helpers")
local gears        = require("gears")

local action_icons = {
    prev = "󰒮",
    next = "󰒭",
    stop = "󰓛",
}

local function show(action)
    awful.spawn.easy_async_with_shell(
        "playerctl metadata --format '{{status}}|{{title}}|{{artist}}'",
        function(out)
            local status, title, artist = out:match("([^|]+)|([^|]+)|([^|]*)")
            if not title or title == "" then return end

            local is_playing  = status and status:lower():match("playing")

            local c_status    = is_playing and beautiful.text_dim or beautiful.text_dim
            local c_title     = is_playing and beautiful.text_base or beautiful.text_base
            local c_artist    = is_playing and beautiful.text_muted or beautiful.text_dim
            local c_icon      = is_playing and beautiful.lavender or beautiful.text_dim
            local c_icon_on   = is_playing and beautiful.bg_raised or beautiful.bg_raised
            local c_icon_bg   = is_playing and beautiful.lavender or beautiful.text_dim

            local status_text = is_playing and "PLAYING" or "PAUSED"

            local right_icon
            if action == "prev" then
                right_icon = action_icons.prev
            elseif action == "next" then
                right_icon = action_icons.next
            elseif action == "stop" then
                right_icon = action_icons.stop
            else
                right_icon = is_playing and "󰐊" or "󰏤"
            end

            naughty.layout.box({
                notification = naughty.notification({
                    app_name = "player",
                    title    = title,
                    message  = artist,
                    timeout  = 3,
                    ignore   = true
                }),
                widget_template = {
                    {
                        {
                            forced_width = beautiful.notification_accent_width,
                            bg           = c_icon,
                            widget       = wibox.container.background,
                        },
                        {
                            {
                                {
                                    {
                                        {
                                            widget = wibox.widget.textbox,
                                            font   = beautiful.font_icon .. " 18",
                                            markup = helpers.colorizeText(beautiful.music, c_icon),
                                            align  = "center",
                                            valign = "center",
                                        },
                                        forced_width  = 48,
                                        forced_height = 48,
                                        bg            = beautiful.bg_overlay,
                                        shape         = helpers.rrect(4),
                                        widget        = wibox.container.background,
                                    },
                                    top    = 10,
                                    bottom = 20,
                                    widget = wibox.container.margin
                                },
                                {
                                    {
                                        widget       = wibox.widget.textbox,
                                        font         = beautiful.font .. " " .. (beautiful.fs_xs),
                                        markup       = helpers.colorizeText(status_text, c_status),
                                        valign       = "center",
                                        forced_width = 100,
                                    },
                                    {
                                        widget        = wibox.widget.textbox,
                                        font          = beautiful.font .. " Medium " .. (beautiful.fs_sm),
                                        markup        = helpers.colorizeText(title, c_title),
                                        ellipsize     = "end",
                                        valign        = "center",
                                        forced_width  = 260,
                                        forced_height = 22,
                                    },
                                    {
                                        widget        = wibox.widget.textbox,
                                        font          = beautiful.font_mono .. " " .. (beautiful.fs_xs),
                                        markup        = helpers.colorizeText(artist ~= "" and artist or "Unknown",
                                            c_artist),
                                        ellipsize     = "end",
                                        valign        = "center",
                                        forced_width  = 100,
                                        forced_height = 22,
                                    },
                                    spacing = 2,
                                    layout  = wibox.layout.fixed.vertical,
                                },
                                {
                                    {
                                        {
                                            widget = wibox.widget.textbox,
                                            font   = beautiful.font_icon .. " 16",
                                            markup = helpers.colorizeText(right_icon, c_icon_on),
                                            align  = "center",
                                            valign = "center",
                                        },
                                        forced_width  = 36,
                                        forced_height = 36,
                                        bg            = c_icon_bg,
                                        shape         = helpers.rrect(999),
                                        widget        = wibox.container.background,
                                    },
                                    top    = 20,
                                    bottom = 20,
                                    widget = wibox.container.margin
                                },
                                spacing = 14,
                                layout  = wibox.layout.fixed.horizontal,
                            },
                            margins = { top = 15, bottom = 0, left = 20, right = 20 },
                            widget  = wibox.container.margin,
                        },
                        layout = wibox.layout.fixed.horizontal,
                    },
                    bg           = beautiful.bg_raised,
                    shape        = helpers.rrect(beautiful.border_radius),
                    forced_width = beautiful.notification_width,
                    widget       = wibox.container.background,
                },
            })
        end
    )
end

local function run(action, cmd)
    awful.spawn.easy_async_with_shell(cmd, function()
        if action == "play_pause" then
            gears.timer({
                timeout     = 0.2,
                autostart   = true,
                single_shot = true,
                callback    = function() show(action) end,
            })
        else
            show(action)
        end
    end)
end

return {
    prev = function()
        run("prev", "playerctl previous")
    end,
    next = function()
        run("next", "playerctl next")
    end,
    play_pause = function()
        run("play_pause", "playerctl play-pause")
    end,
    stop = function()
        run("stop", "playerctl stop")
    end,
}
