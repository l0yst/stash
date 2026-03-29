local beautiful = require("beautiful")
local gears     = require("gears")
local awful     = require("awful")
require("awful.autofocus")

beautiful.init(gears.filesystem.get_configuration_dir() .. "theme.lua")

require("base")
require("ui")

local function set_wallpaper(s)
    if beautiful.wallpaper then
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end

screen.connect_signal("property::geometry", set_wallpaper)
awful.screen.connect_for_each_screen(set_wallpaper)
