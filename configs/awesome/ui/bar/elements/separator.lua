local wibox     = require("wibox")
local beautiful = require("beautiful")

local M         = {}

function M.new()
    return wibox.widget {
        {
            forced_width  = beautiful.sep_width,
            forced_height = beautiful.sep_height,
            bg            = beautiful.bg_border,
            widget        = wibox.container.background,
        },
        top    = beautiful.sep_height,
        bottom = beautiful.sep_height,
        widget = wibox.container.margin,
    }
end

return M
