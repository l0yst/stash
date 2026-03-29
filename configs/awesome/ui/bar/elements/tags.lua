local awful     = require("awful")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local helpers   = require("base.helpers")
local gears     = require("gears")

local M         = {}

local function update_tag(self, t)
    local icon_widget = self:get_children_by_id("icon_role")[1]

    local icon
    local color
    if t.selected then
        icon  = beautiful.icon_tag_focused
        color = beautiful.tag_focused
    elseif t.urgent then
        icon  = beautiful.icon_tag_urgent
        color = beautiful.tag_urgent
    elseif #t:clients() > 0 then
        icon  = beautiful.icon_tag_occupied
        color = beautiful.tag_occupied
    else
        icon  = beautiful.icon_tag_empty
        color = beautiful.tag_empty
    end

    icon_widget.markup = helpers.colorizeText(icon, color)
end

function M.new(s)
    local buttons = gears.table.join(
        awful.button({}, 1, function(t) t:view_only() end),
        awful.button({ "Mod4" }, 1, function(t)
            if client.focus then
                client.focus:move_to_tag(t)
            end
        end)
    )

    return awful.widget.taglist {
        screen          = s,
        filter          = awful.widget.taglist.filter.all,
        buttons         = buttons,
        layout          = {
            layout  = wibox.layout.fixed.horizontal,
            spacing = beautiful.tags_spacing,
        },
        widget_template = {
            {
                id     = "icon_role",
                widget = wibox.widget.textbox,
                align  = "center",
                valign = "center",
                font   = beautiful.font_icon .. " " .. beautiful.fs_md,
            },
            id              = "background_role",
            widget          = wibox.container.background,

            create_callback = update_tag,
            update_callback = update_tag,
        },
    }
end

return M
