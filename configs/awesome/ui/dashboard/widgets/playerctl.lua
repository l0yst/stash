local wibox             = require("wibox")
local beautiful         = require("beautiful")
local helpers           = require("base.helpers")
local awful             = require("awful")
local gears             = require("gears")

-- ── Widgets ───────────────────────────────────────────────────────────────
local title_text        = wibox.widget({
    widget        = wibox.widget.textbox,
    font          = "DM Sans Medium " .. beautiful.fs_sm,
    markup        = helpers.colorizeText("Not Playing", beautiful.text_muted),
    align         = "left",
    forced_width  = 270,
    forced_height = 20,
    ellipsize     = "end",
    valign        = "center",
})

local artist_text       = wibox.widget({
    widget = wibox.widget.textbox,
    font   = beautiful.font_mono .. " " .. beautiful.fs_xs,
    markup = helpers.colorizeText("Nothing to show", beautiful.text_dim),
    align  = "left",
    valign = "center",
})

local cover_placeholder = wibox.widget({
    widget = wibox.widget.textbox,
    font   = beautiful.font_icon .. " " .. beautiful.fs_lg,
    markup = helpers.colorizeText(beautiful.music, beautiful.lavender),
    align  = "center",
    valign = "center",
})

local cover             = wibox.widget({
    widget        = wibox.widget.imagebox,
    image         = nil,
    resize        = true,
    forced_width  = 48,
    forced_height = 48,
})

local cover_box         = wibox.widget({
    {
        cover_placeholder,
        cover,
        layout = wibox.layout.stack,
    },
    bg            = beautiful.bg_overlay,
    shape         = helpers.rrect(6),
    forced_width  = 48,
    forced_height = 48,
    widget        = wibox.container.background,
})

local prev_btn          = wibox.widget({
    widget = wibox.widget.textbox,
    font   = beautiful.font_icon .. " " .. beautiful.fs_md,
    markup = helpers.colorizeText("󰒮", beautiful.text_dim),
    align  = "center",
    valign = "center",
})

local play_icon         = wibox.widget({
    widget = wibox.widget.textbox,
    font   = beautiful.font_icon .. " " .. beautiful.fs_md,
    markup = helpers.colorizeText("󰐊", beautiful.bg_raised),
    align  = "center",
    valign = "center",
})

local play_btn          = wibox.widget({
    { play_icon, left = 12, right = 12, widget = wibox.container.margin },
    bg     = beautiful.sky,
    shape  = helpers.rrect(999),
    widget = wibox.container.background,
})

local next_btn          = wibox.widget({
    widget = wibox.widget.textbox,
    font   = beautiful.font_icon .. " " .. beautiful.fs_md,
    markup = helpers.colorizeText("󰒭", beautiful.text_dim),
    align  = "center",
    valign = "center",
})

local progress          = wibox.widget({
    widget           = wibox.widget.progressbar,
    forced_height    = beautiful.p_bar_height,
    forced_width     = 120,
    shape            = helpers.rrect(6),
    bar_shape        = helpers.rrect(6),
    background_color = beautiful.bg_border,
    color            = beautiful.sky,
    value            = 0,
    max_value        = 100,
})

local widget            = wibox.widget({
    {
        cover_box,
        {
            title_text,
            artist_text,
            layout  = wibox.layout.fixed.vertical,
            spacing = 4,
        },
        layout  = wibox.layout.fixed.horizontal,
        spacing = 12,
    },
    { layout = wibox.layout.fixed.horizontal },
    {
        {
            {
                prev_btn,
                play_btn,
                next_btn,
                layout  = wibox.layout.fixed.horizontal,
                spacing = 16,
            },
            margins = 6,
            widget = wibox.container.margin
        },
        {
            progress,
            valign = "center",
            halign = "center",
            widget = wibox.container.place,
        },
        layout  = wibox.layout.fixed.horizontal,
        spacing = 12,
    },
    layout = wibox.layout.align.horizontal,
})

-- ── Cover loader ──────────────────────────────────────────────────────────
local function load_cover(art)
    if not art or art == "" then
        cover.image               = nil
        cover.visible             = false
        cover_placeholder.visible = true
        return
    end
    if art:match("^file://") then
        cover.image               = art:gsub("file://", "")
        cover.visible             = true
        cover_placeholder.visible = false
    elseif art:match("^https?://") then
        local tmp = "/tmp/awesome_cover.jpg"
        awful.spawn.easy_async_with_shell(
            "curl -sf --max-time 5 -o " .. tmp .. " '" .. art .. "'",
            function()
                cover.image               = tmp
                cover.visible             = true
                cover_placeholder.visible = false
            end
        )
    end
end

local function update_progress()
    awful.spawn.easy_async_with_shell(
        "playerctl metadata --format '{{position}}|{{mpris:length}}' 2>/dev/null",
        function(out)
            local pos, len = out:match("(%d+)|(%d+)")
            if pos and len and tonumber(len) > 0 then
                progress.value = (tonumber(pos) / tonumber(len)) * 100
            end
        end
    )
end

local prog_timer = gears.timer({
    timeout  = 2,
    callback = update_progress,
})

local status     = "Stopped"
local follow_pid = nil

local function update_ui(s, title, artist, art)
    status             = s or "Stopped"

    title_text.markup  = helpers.colorizeText(title ~= "" and title or "Not Playing", beautiful.text_muted)
    artist_text.markup = helpers.colorizeText(artist ~= "" and artist or "Nothing to show", beautiful.text_dim)

    load_cover(art)

    play_icon.markup = helpers.colorizeText(
        status == "Playing" and "󰏤" or "󰐊",
        beautiful.bg_raised
    )

    if status == "Playing" then
        if not prog_timer.started then prog_timer:start() end
    else
        prog_timer:stop()
        update_progress()
    end
end

local function start_follow()
    if follow_pid then return end
    follow_pid = awful.spawn.with_line_callback(
        "playerctl --follow metadata --format '{{status}}|{{title}}|{{artist}}|{{mpris:artUrl}}' 2>/dev/null",
        {
            stdout = function(line)
                local s, title, artist, art = line:match("([^|]+)|([^|]*)|([^|]*)|([^|]*)")
                if s then update_ui(s, title, artist, art) end
            end,
            exit = function()
                follow_pid = nil
                update_ui("Stopped", "", "", "")
            end,
        }
    )
end

helpers.onClick(prev_btn, 1, function() awful.spawn("playerctl previous") end)
helpers.onClick(play_btn, 1, function() awful.spawn("playerctl play-pause") end)
helpers.onClick(next_btn, 1, function() awful.spawn("playerctl next") end)
helpers.hoverCursor(prev_btn)
helpers.hoverCursor(play_btn)
helpers.hoverCursor(next_btn)

-- ── Lifecycle ─────────────────────────────────────────────────────────────
function widget.refresh()
    start_follow()
end

function widget.stop()
    prog_timer:stop()
    if follow_pid then
        awesome.kill(follow_pid, 9)
        follow_pid = nil
    end
end

return widget
