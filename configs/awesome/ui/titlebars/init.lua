local wibox     = require("wibox")
local awful     = require("awful")
local gears     = require("gears")
local beautiful = require("beautiful")
local helpers   = require("base.helpers")

local function should_exclude(c)
	if c.class then
		for _, cls in ipairs(beautiful.titlebar_exclude_classes) do
			if c.class:lower():match(cls:lower()) then return true end
		end
	end
	if c.type then
		for _, t in ipairs(beautiful.titlebar_exclude_types) do
			if c.type == t then return true end
		end
	end
	return false
end

local button_colors = {
	close    = { normal = beautiful.close_color, inactive = beautiful.inactive_color },
	maximize = { normal = beautiful.max_color, inactive = beautiful.inactive_color },
	ontop    = {
		normal = beautiful.ontop_color,
		inactive = beautiful.inactive_color,
		ontop = beautiful.ontop_off
	},
}

local function create_button(color_scheme, action, c)
	local dot = wibox.widget({
		widget        = wibox.container.background,
		bg            = color_scheme.inactive,
		shape         = gears.shape.circle,
		forced_width  = beautiful.circle_size,
		forced_height = beautiful.circle_size,
	})

	local function update_color()
		if color_scheme.ontop and c.ontop then
			dot.bg = color_scheme.ontop
		elseif c ~= client.focus then
			dot.bg = color_scheme.inactive
		else
			dot.bg = color_scheme.normal
		end
	end

	dot:buttons(gears.table.join(
		awful.button({}, 1, function()
			action(c)
			update_color()
		end)
	))

	return dot, update_color
end

local titlebar_state = setmetatable({}, { __mode = "k" })

local function update_visibility(c)
	if not c or not c.valid then return end
	if should_exclude(c) then
		awful.titlebar.hide(c)
		return
	end
	local tag         = c.first_tag or c.screen.selected_tag
	local layout      = tag and tag.layout or nil
	local should_show = c.floating or layout == awful.layout.suit.floating
	if titlebar_state[c] == should_show then return end
	titlebar_state[c] = should_show
	if should_show then
		awful.titlebar.show(c)
	else
		awful.titlebar.hide(c)
	end
end

client.connect_signal("request::titlebars", function(c)
	if should_exclude(c) then
		awful.titlebar.hide(c)
		return
	end

	local close_btn, close_update = create_button(button_colors.close, function(cl)
		cl:kill()
	end, c)

	local max_btn, max_update = create_button(button_colors.maximize, function(cl)
		cl.maximized = not cl.maximized
	end, c)

	local ontop_btn, ontop_update = create_button(button_colors.ontop, function(cl)
		cl.ontop = not cl.ontop
	end, c)
	c:connect_signal("property::ontop", ontop_update)

	-- Title
	local title = wibox.widget({
		widget = wibox.widget.textbox,
		font   = beautiful.font_mono .. " Regular " .. beautiful.fs_xs,
		align  = "left",
		valign = "center",
	})

	local function update_title()
		title.markup = helpers.colorizeText(
			c.name or "unknown",
			c == client.focus and beautiful.tb_text_color or beautiful.tb_inactive_text_color
		)
	end

	local function update_all()
		close_update()
		max_update()
		ontop_update()
		update_title()
	end
	c:connect_signal("focus", update_all)
	c:connect_signal("unfocus", update_all)
	c:connect_signal("property::name", update_title)

	update_title()

	awful.titlebar(c, {
		size     = beautiful.titlebar_height,
		bg       = beautiful.titlebar_color,
		position = beautiful.titlebar_pos,
	}):setup({
		{
			{
				{
					close_btn,
					max_btn,
					ontop_btn,
					spacing = beautiful.widget_padding,
					layout  = wibox.layout.fixed.horizontal,
				},
				helpers.pad(title, 0, 0, 16, 0),
				layout = wibox.layout.fixed.horizontal,
			},
			{
				buttons = awful.util.table.join(
					awful.button({}, 1, function()
						c:activate({ context = "titlebar", action = "mouse_move" })
					end),
					awful.button({}, 3, function()
						c:activate({ context = "titlebar", action = "mouse_resize" })
					end)
				),
				layout = wibox.layout.flex.horizontal,
			},
			layout = wibox.layout.align.horizontal,
		},
		margins = { top = 10, bottom = 10, left = 12, right = 12 },
		widget  = wibox.container.margin,
	})

	close_update()
	max_update()
	ontop_update()
	update_visibility(c)
end)

client.connect_signal("property::floating", update_visibility)

tag.connect_signal("property::layout", function(t)
	local s = awful.screen.focused()
	if t.screen ~= s then return end
	for _, c in ipairs(t:clients()) do
		update_visibility(c)
	end
end)
client.connect_signal("property::maximized", update_visibility)
