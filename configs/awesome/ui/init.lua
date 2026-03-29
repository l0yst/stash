local awful = require("awful")
local bar = require("ui.bar")
require("ui.titlebars")
require("ui.naughty")

awful.screen.connect_for_each_screen(function(s)
    bar.setup(s)
end)
