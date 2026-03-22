local awful                               = require("awful")

local client_instance                     = nil
local visible                             = false

awful.rules.rules[#awful.rules.rules + 1] = {
    rule       = { instance = "scratchpad" },
    properties = {
        floating     = true,
        sticky       = true,
        ontop        = true,
        skip_taskbar = true,
        above        = true,
        focusable    = true,
    },
    callback   = function(c)
        client_instance = c

        local s         = awful.screen.focused()
        local geo       = {
            x      = s.geometry.x,
            y      = s.geometry.y + s.geometry.height * 0.6,
            width  = s.geometry.width,
            height = s.geometry.height * 0.4,
        }
        c:geometry(geo)
        c.visible = false

        c:connect_signal("unmanage", function()
            client_instance = nil
            visible         = false
        end)
    end,
}

local function toggle()
    if not client_instance then
        awful.spawn("wezterm start --class scratchpad", false)
        visible = true
        return
    end

    visible = not visible

    if visible then
        local s = awful.screen.focused()
        client_instance:geometry({
            x      = s.geometry.x,
            y      = s.geometry.y + s.geometry.height * 0.6,
            width  = s.geometry.width,
            height = s.geometry.height * 0.4,
        })
        client_instance.minimized = false
        client.focus              = client_instance
        client_instance:raise()
    else
        client_instance.minimized = true
    end
end

return { toggle = toggle }
