local awful                          = require("awful")
local wibox                          = require("wibox")
local beautiful                      = require("beautiful")
local helpers                        = require("base.helpers")
local weather                        = require("ui.dashboard.widgets.weather")
local naughty                        = require("naughty")

local pfp_box                        = wibox.widget({
    widget        = wibox.widget.imagebox,
    image         = beautiful.pfp,
    resize        = true,
    clip_shape    = helpers.rrect(999),
    forced_width  = 80,
    forced_height = 80,
    valign        = "center",
    halign        = "center",
})

local username                       = wibox.widget({
    widget = wibox.widget.textbox,
    font   = "DM Sans Bold " .. beautiful.fs_md,
    markup = helpers.colorizeText(beautiful.dashboard_user, beautiful.text_base),
    align  = "left",
    valign = "center",
})

local sysinfo                        = wibox.widget({
    widget = wibox.widget.textbox,
    font   = beautiful.font_mono .. " " .. beautiful.fs_xs,
    markup = helpers.colorizeText("...", beautiful.text_dim),
    align  = "left",
    valign = "center",
})

local date                           = wibox.widget({
    widget = wibox.widget.textbox,
    font   = beautiful.font_mono .. " " .. beautiful.fs_xs,
    markup = helpers.colorizeText(os.date("%A, %d %B"), beautiful.text_dim),
    align  = "right",
    valign = "center",
})

local left                           = wibox.widget({
    pfp_box,
    {
        {
            username,
            sysinfo,
            layout = wibox.layout.fixed.vertical,
            spacing = 6
        },
        valign = "center",
        widget = wibox.container.place,
    },
    layout = wibox.layout.fixed.horizontal,
    spacing = 16,
})

local right                          = wibox.widget({
    weather,
    date,
    layout  = wibox.layout.fixed.vertical,
    spacing = 2,
})

local widget                         = wibox.widget({
    left,
    right,
    layout = wibox.layout.align.horizontal,
})

-- ── Sysinfo state ─────────────────────────────────────────────────────────
local kernel_val                     = "linux"
local uptime_val                     = "--"
local update_val                     = "..."
local update_cache, last_update_time = nil, 0

local function render()
    local dim      = beautiful.text_dim
    local dot      = helpers.colorizeText(" · ", dim)
    sysinfo.markup =
        helpers.colorizeText(kernel_val, dim) .. dot ..
        helpers.colorizeText(uptime_val, dim) .. dot ..
        helpers.colorizeText(update_val, beautiful.text_dim)
end

-- Kernel: run once at load (doesn't change until reboot)
awful.spawn.easy_async({ "uname", "-r" }, function(stdout)
    local k = stdout:gsub("%s+", "")
    kernel_val = k:match("zen") or k:match("lts") or k:match("hardened") or k:match("rt") or "linux"
    render()
end)

local function fetch_uptime()
    awful.spawn.easy_async({ "uptime", "-p" }, function(stdout)
        uptime_val = "up " .. stdout
            :gsub("^up%s+", "")
            :gsub(" hours?", "h")
            :gsub(" minutes?", "m")
            :gsub(",", "")
            :gsub("%s+", " ")
            :gsub("\n", "")
        render()
    end)
end

local function fetch_updates()
    if update_cache and os.time() - last_update_time < 3600 then
        update_val = update_cache
        render()
        return
    end
    awful.spawn.easy_async_with_shell(
        "(checkupdates 2>/dev/null; paru -Qua 2>/dev/null) | wc -l",
        function(out)
            local count      = tonumber(out:match("%d+")) or 0
            update_cache     = count == 0 and "no updates" or count .. " updates"
            last_update_time = os.time()
            update_val       = update_cache
            if count >= 50 then
                naughty.notify({
                    title    = "System Updates",
                    text     = "You have packages to be updated! Please update them!",
                    urgency  = "critical",
                    timeout  = 0,
                    app_name = "pacman",
                })
            end
            render()
        end
    )
end

function widget.refresh()
    fetch_uptime()
    fetch_updates()
    weather.refresh()
    date.markup = helpers.colorizeText(os.date("%A, %d %B %Y"), beautiful.text_dim)
end

return widget
