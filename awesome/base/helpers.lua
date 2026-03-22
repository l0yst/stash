local helpers = {}

local beautiful = require("beautiful")
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")


helpers.box = function(widget, bg, shape)
    return wibox.widget({
        widget,
        bg     = bg,
        shape  = shape or helpers.rrect(0),
        widget = wibox.container.background,
    })
end

helpers.pad = function(widget, top, bottom, left, right)
    return wibox.widget({
        widget,
        top    = top or 0,
        bottom = bottom or 0,
        left   = left or 0,
        right  = right or 0,
        widget = wibox.container.margin,
    })
end

helpers.onClick = function(w, btn, fn)
    w:connect_signal("button::press", function(_, _, _, b)
        if b == btn then fn() end
    end)
end

helpers.text = function(opts)
    opts = opts or {}

    local tb = wibox.widget({
        markup = opts.markup,
        text   = opts.markup and nil or (opts.text or ""),
        font   = (opts.font or "JetBrains Mono")
            .. " "
            .. (opts.weight or "Regular")
            .. " "
            .. (opts.size or 10),
        align  = opts.align or "left",
        valign = opts.valign or "center",
        widget = wibox.widget.textbox,
    })

    local widget = {
        {
            tb,
            top    = opts.pad_top or opts.pad or 0,
            bottom = opts.pad_bottom or opts.pad or 0,
            left   = opts.pad_left or opts.pad or 0,
            right  = opts.pad_right or opts.pad or 0,
            widget = wibox.container.margin,
        },
        fg           = opts.fg or beautiful.fg,
        bg           = opts.bg,
        shape        = helpers.rrect(opts.radius or 4),
        border_width = opts.border_width or 0,
        border_color = opts.border_color or "transparent",
        widget       = wibox.container.background,
    }

    return wibox.widget(widget)
end

helpers.rrect = function(radius)
    radius = radius or 4
    return function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, radius)
    end
end

helpers.rounded = function(top_left, top_right, bottom_right, bottom_left)
    if top_right == nil and bottom_right == nil and bottom_left == nil then
        local radius = type(top_left) == "number" and top_left or 5
        return function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, radius)
        end
    end

    local tl = type(top_left) == "number" and top_left or 0
    local tr = type(top_right) == "number" and top_right or 0
    local br = type(bottom_right) == "number" and bottom_right or 0
    local bl = type(bottom_left) == "number" and bottom_left or 0

    local radius = math.max(tl, tr, br, bl)

    return function(cr, width, height)
        gears.shape.partially_rounded_rect(
            cr,
            width,
            height,
            tl > 0,
            tr > 0,
            br > 0,
            bl > 0,
            radius
        )
    end
end

helpers.colorizeText = function(txt, fg)
    if fg == "" then
        fg = "#ffffff"
    end

    return "<span foreground='" .. fg .. "'>" .. txt .. "</span>"
end

function helpers.hoverCursor(w, cursorType)
    cursorType = cursorType or "hand2"
    local oldCursor = "left_ptr"
    local wbx

    w.hcDisabled = false
    local enterCb = function()
        wbx = mouse.current_wibox
        if wbx then
            wbx.cursor = cursorType
        end
    end
    local leaveCb = function()
        if wbx then
            wbx.cursor = oldCursor
        end
    end

    w:connect_signal("hover::disconnect", function()
        w:disconnect_signal("mouse::enter", enterCb)
        w:disconnect_signal("mouse::leave", leaveCb)
        leaveCb()
    end)

    function w:toggleHoverCursor()
        w.hcDisabled = not w.hcDisabled
        if w.hcDisabled then
            leaveCb()
        else
            enterCb()
        end
    end

    w:connect_signal("mouse::enter", enterCb)
    w:connect_signal("mouse::leave", leaveCb)
end

local floating_resize_amount = 20
local tiling_resize_factor = 0.10

helpers.resize_client = function(c, direction)
    if not c then return end
    local layout = awful.layout.get(c.screen)

    if c.floating or layout == awful.layout.suit.floating then
        if direction == "up" then
            c:relative_move(0, 0, 0, -floating_resize_amount)
        elseif direction == "down" then
            c:relative_move(0, 0, 0, floating_resize_amount)
        elseif direction == "left" then
            c:relative_move(0, 0, -floating_resize_amount, 0)
        elseif direction == "right" then
            c:relative_move(0, 0, floating_resize_amount, 0)
        end
        return
    end

    if direction == "up" then
        awful.client.incwfact(-tiling_resize_factor)
    elseif direction == "down" then
        awful.client.incwfact(tiling_resize_factor)
    elseif direction == "left" then
        awful.tag.incmwfact(-tiling_resize_factor)
    elseif direction == "right" then
        awful.tag.incmwfact(tiling_resize_factor)
    end
end

function helpers.centered_client_placement(c)
    return gears.timer.delayed_call(function()
        awful.placement.centered(c, { honor_padding = true, honor_workarea = true })
    end)
end

return helpers
