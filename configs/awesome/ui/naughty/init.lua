local naughty = require("naughty")
local wibox = require("wibox")
local beautiful = require("beautiful")
local helpers = require("base.helpers")

naughty.config.defaults.timeout = beautiful.notification_timeout
naughty.config.defaults.position = beautiful.notification_position

local accent = {
	low = beautiful.sand,
	normal = beautiful.sky,
	critical = beautiful.rose,
}

local app_icons = {
	spotify = "♪",
	zen = "󰈹",
	pacman = "󰮯",
	yay = "󰮯",
	network = "󰤨",
	vesktop = "󰙯",
	nvim = "󰝆",
	nautilus = "󰉋",
	system = "󰃓",
	power = "󰓅",
	clean = "󰇾",
	screenshot = "󱏘",
	redshift = "󰽥",
	mic = beautiful.mic,
	gamemode = beautiful.gamemode,
}

local function get_symbol(app_name)
	if not app_name then
		return "󰝆"
	end
	return app_icons[app_name:lower()] or "󰃓"
end

naughty.connect_signal("request::display", function(n)
	local color = accent[n.urgency] or beautiful.sky
	local symbol = get_symbol(n.app_name)
	local app = n.app_name or "system"
	if n.app_name == "player" then
		return
	end

	local top_row = wibox.widget({
		{
			widget = wibox.widget.textbox,
			font = beautiful.font .. " " .. beautiful.fs_xs,
			markup = helpers.colorizeText(app:upper(), beautiful.text_dim),
			valign = "center",
		},
		nil,
		{
			widget = wibox.widget.textbox,
			font = beautiful.font_mono .. " " .. beautiful.fs_xs,
			markup = helpers.colorizeText(os.date("%I:%M"), beautiful.text_dim),
			align = "right",
			valign = "center",
		},
		layout = wibox.layout.align.horizontal,
	})

	local title_w = wibox.widget({
		widget = naughty.widget.title,
		forced_height = 17,
		ellipsize = "end",
	})

	local msg_w = wibox.container.constraint(
		wibox.widget({
			widget = wibox.widget.textbox,
			font = beautiful.font_mono .. " Regular " .. beautiful.fs_xs,
			markup = helpers.colorizeText(n.message or "", beautiful.text_muted),
			ellipsize = "end",
			wrap = "word_char",
		}),
		"max",
		nil,
		48
	)

	local icon_w = wibox.widget({
		{
			widget = wibox.widget.textbox,
			font = beautiful.font .. " 14",
			markup = helpers.colorizeText(symbol, color),
			align = "center",
			valign = "top",
			forced_width = 24,
		},
		top = 8,
		widget = wibox.container.margin,
	})

	local text_col = wibox.container.constraint(
		wibox.widget({
			top_row,
			title_w,
			msg_w,
			spacing = 5,
			layout = wibox.layout.fixed.vertical,
		}),
		"exact",
		beautiful.notification_width - 40
	)

	naughty.layout.box({
		notification = n,
		type = "notification",
		widget_template = {
			{
				{
					forced_width = beautiful.notification_accent_width,
					bg = color,
					widget = wibox.container.background,
				},
				{
					{
						icon_w,
						text_col,
						spacing = 10,
						layout = wibox.layout.fixed.horizontal,
					},
					margins = beautiful.notification_spacing,
					widget = wibox.container.margin,
				},
				layout = wibox.layout.fixed.horizontal,
			},
			bg = beautiful.bg_raised,
			shape = helpers.rrect(beautiful.border_radius),
			forced_width = beautiful.notification_width,
			widget = wibox.container.background,
		},
	})
end)
