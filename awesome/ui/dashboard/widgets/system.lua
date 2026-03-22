local wibox     = require("wibox")
local beautiful = require("beautiful")
local helpers   = require("base.helpers")
local gears     = require("gears")
local awful     = require("awful")

-- ── Row builder ───────────────────────────────────────────────────────────
local function make_row(label, color)
    local label_w = wibox.widget({
        widget       = wibox.widget.textbox,
        font         = beautiful.font_mono .. " " .. beautiful.fs_xs,
        markup       = helpers.colorizeText(label, beautiful.text_dim),
        align        = "left",
        valign       = "center",
        forced_width = 40,
    })
    local bar = wibox.widget({
        widget           = wibox.widget.progressbar,
        forced_width     = beautiful.p_bar_width,
        forced_height    = beautiful.p_bar_height,
        shape            = helpers.rrect(6),
        bar_shape        = helpers.rrect(6),
        background_color = beautiful.bg_border,
        color            = color,
        value            = 0,
        max_value        = 100,
    })
    local val_w = wibox.widget({
        widget       = wibox.widget.textbox,
        font         = beautiful.font_mono .. " " .. beautiful.fs_xs,
        markup       = helpers.colorizeText("0%", beautiful.text_muted),
        align        = "right",
        valign       = "center",
        forced_width = 32,
    })
    local row = wibox.widget({
        label_w,
        { bar, valign = "center", halign = "center", widget = wibox.container.place },
        val_w,
        layout = wibox.layout.align.horizontal,
    })
    local function update(pct)
        bar.value    = pct
        val_w.markup = helpers.colorizeText(math.floor(pct) .. "%", beautiful.text_muted)
    end
    return row, update
end

-- ── Widgets ───────────────────────────────────────────────────────────────
local label                 = wibox.widget({
    widget = wibox.widget.textbox,
    font   = beautiful.font_mono .. " " .. beautiful.fs_xs,
    markup = helpers.colorizeText("SYSTEM", beautiful.text_dim),
    align  = "left",
    valign = "center",
})

local vol_label             = wibox.widget({
    widget       = wibox.widget.textbox,
    font         = beautiful.font_mono .. " " .. beautiful.fs_xs,
    markup       = helpers.colorizeText("vol", beautiful.text_dim),
    align        = "left",
    valign       = "center",
    forced_width = 50,
})

local slider_inner          = wibox.widget({
    widget              = wibox.widget.slider,
    value               = 50,
    minimum             = 0,
    maximum             = 100,
    forced_width        = beautiful.p_bar_width,
    forced_height       = beautiful.p_bar_height,
    bar_height          = beautiful.p_bar_height,
    bar_color           = beautiful.bg_border,
    bar_active_color    = beautiful.mauve,
    bar_shape           = gears.shape.rounded_bar,
    handle_width        = 14,
    handle_color        = beautiful.mauve,
    handle_shape        = gears.shape.circle,
    handle_border_width = 3,
    handle_border_color = beautiful.bg_overlay,
})

local slider                = wibox.widget({
    slider_inner,
    forced_height = 0,
    layout        = wibox.container.constraint,
})

local vol_val               = wibox.widget({
    widget       = wibox.widget.textbox,
    font         = beautiful.font_mono .. " " .. beautiful.fs_xs,
    markup       = helpers.colorizeText("0%", beautiful.text_muted),
    align        = "right",
    valign       = "center",
    forced_width = 40,
})

local vol_row               = wibox.widget({
    vol_label,
    slider,
    vol_val,
    layout = wibox.layout.align.horizontal,
})

local cpu_row, cpu_update   = make_row("cpu", beautiful.sky)
local ram_row, ram_update   = make_row("mem", beautiful.teal)
local disk_row, disk_update = make_row("disk", beautiful.sage)

-- ── CPU: read /proc/stat directly (no spawn) ──────────────────────────────
local prev_idle, prev_total = 0, 0

local function read_cpu()
    local f = io.open("/proc/stat")
    if not f then return 0 end
    local line = f:read("*l")
    f:close()
    local vals = {}
    for v in line:gmatch("%d+") do table.insert(vals, tonumber(v)) end
    local idle  = vals[4]
    local total = 0
    for _, v in ipairs(vals) do total = total + v end
    local d_idle          = idle - prev_idle
    local d_total         = total - prev_total
    prev_idle, prev_total = idle, total
    if d_total == 0 then return 0 end
    return (1 - d_idle / d_total) * 100
end

-- ── RAM: read /proc/meminfo directly (no spawn) ───────────────────────────
local function read_ram()
    local f = io.open("/proc/meminfo")
    if not f then return 0 end
    local total, available
    for line in f:lines() do
        local k, v = line:match("(%w+):%s+(%d+)")
        if k == "MemTotal" then total = tonumber(v) end
        if k == "MemAvailable" then available = tonumber(v) end
        if total and available then break end
    end
    f:close()
    if not total or total == 0 then return 0 end
    return ((total - available) / total) * 100
end

-- ── Disk: async spawn, cached 60s ────────────────────────────────────────
local last_disk_time  = 0
local last_disk_value = 0

local function read_disk()
    local now = os.time()
    if now - last_disk_time < 60 then
        disk_update(last_disk_value)
        return
    end
    last_disk_time = now
    awful.spawn.easy_async_with_shell(
        "df / --output=pcent | tail -1 | tr -d ' %'",
        function(out)
            local pct       = tonumber(out:match("%d+")) or 0
            last_disk_value = pct
            disk_update(pct)
        end
    )
end

-- ── Volume: async, ────────────────────────────
local is_user_changing = false

local function fetch_volume()
    if is_user_changing then return end

    awful.spawn.easy_async(
        { "pactl", "get-sink-volume", "@DEFAULT_SINK@" },
        function(out)
            local v = tonumber(out:match("(%d?%d?%d)%%")) or 0
            if math.abs(slider_inner.value - v) > 1 then
                slider_inner.value = v
            end
            vol_val.markup = helpers.colorizeText(v .. "%", beautiful.text_muted)
        end
    )
end

slider_inner:connect_signal("property::value", function()
    is_user_changing = true

    local v = math.floor(slider_inner.value)
    vol_val.markup = helpers.colorizeText(v .. "%", beautiful.text_muted)

    awful.spawn(
        { "pactl", "set-sink-volume", "@DEFAULT_SINK@", v .. "%" },
        false
    )
end)

slider_inner:connect_signal("button::release", function()
    is_user_changing = false
end)

-- ── Poll: runs only while dashboard is open ───────────────────────────────
local function poll()
    cpu_update(read_cpu())
    ram_update(read_ram())
    read_disk()
    fetch_volume()
end

local poll_timer = gears.timer({
    timeout  = 3,
    callback = poll,
})

-- ── Widget ────────────────────────────────────────────────────────────────
local widget = wibox.widget({
    label,
    cpu_row,
    ram_row,
    disk_row,
    vol_row,
    layout  = wibox.layout.fixed.vertical,
    spacing = 8,
})

function widget.refresh()
    poll()
    if not poll_timer.started then
        poll_timer:start()
    end
end

function widget.stop()
    poll_timer:stop()
end

return widget
