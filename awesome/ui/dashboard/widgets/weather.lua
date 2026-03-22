local awful      = require("awful")
local wibox      = require("wibox")
local beautiful  = require("beautiful")
local helpers    = require("base.helpers")

local CACHE_TIME = 1800
local last_fetch = 0

local temp_text  = wibox.widget({
    widget = wibox.widget.textbox,
    font   = "DM Sans Medium 22",
    markup = helpers.colorizeText("-- °C", beautiful.text_base),
    align  = "right",
    valign = "top",
})

local widget     = wibox.widget({
    temp_text,
    layout = wibox.layout.fixed.vertical,
})

local function fetch()
    local now = os.time()
    if now - last_fetch < CACHE_TIME then return end
    last_fetch = now

    local url = "https://api.open-meteo.com/v1/forecast?latitude=" ..
        beautiful.weather_lat ..
        "&longitude=" .. beautiful.weather_lon ..
        "&current_weather=true&temperature_unit=celsius"

    awful.spawn.easy_async(
        { "curl", "-sf", "--max-time", "8", url },
        function(stdout)
            if stdout and stdout ~= "" then
                local temp = stdout:match('"temperature":([%d%.%-]+)')
                if temp then
                    temp_text.markup = helpers.colorizeText(temp .. " °C", beautiful.text_base)
                end
            end
        end
    )
end

function widget.refresh()
    fetch()
end

return widget
