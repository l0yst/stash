local awful          = require("awful")
local beautiful      = require("beautiful")

awful.layout.layouts = {
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.floating,
}

awful.screen.connect_for_each_screen(function(s)
    awful.tag({ "1", "2", "3", "4", "5" }, s, awful.layout.layouts[1])
end)

screen.connect_signal("request::desktop_decoration", function(s)
    local p = beautiful.screen_padding or 8
    s.padding = { top = p, bottom = p, left = p, right = p }
end)

client.connect_signal("mouse::enter", function(c)
    c:activate({ context = "mouse_enter", raise = false })
end)

client.connect_signal("manage", function(c)
    if not awesome.startup then
        awful.client.setslave(c)
    end
    if awesome.startup
        and not c.size_hints.user_position
        and not c.size_hints.program_position then
        awful.placement.no_offscreen(c)
    end
end)

client.connect_signal("property::floating", function(c)
    c.ontop = c.floating
    if c.floating then
        awful.placement.centered(c, { honor_workarea = true, honor_padding = true })
    end
end)

client.connect_signal("property::fullscreen", function(c)
    c:raise()
    if c.fullscreen then
        c.border_width = 0
    else
        c.border_width = beautiful.border_width or 2
    end
end)

client.connect_signal("property::maximized", function(c)
    c.border_width = c.maximized and 0 or (beautiful.border_width or 2)
end)

client.connect_signal("focus", function(c)
    c.border_color = beautiful.border_focus
end)

client.connect_signal("unfocus", function(c)
    c.border_color = beautiful.border_normal
end)

client.connect_signal("unmanage", function(c)
    local s = c.screen
    if s and s.valid then
        awful.layout.arrange(s)
    end
end)

awesome.connect_signal("exit", function()
    awful.spawn.with_shell("pkill -f 'pactl subscribe'")
end)
