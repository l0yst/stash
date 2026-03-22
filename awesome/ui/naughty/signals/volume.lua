local awful        = require("awful")
local wibox        = require("wibox")
local beautiful    = require("beautiful")
local helpers      = require("base.helpers")
local gears        = require("gears")

local WIDTH        = beautiful.notification_volume_width
local HIDE_DELAY   = beautiful.notification_volume_delay
local hide_timer   = nil
local update_timer = nil

local function get_info(callback)
	awful.spawn.easy_async_with_shell(
		"pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\\d+(?=%)' | head -1 && " ..
		"pactl get-sink-mute @DEFAULT_SINK@ | grep -oP '(?<=Mute: )\\w+' && " ..
		"pactl list sinks | grep 'Active Port' | awk '{print $3}'",
		function(out)
			local lines = {}
			for line in out:gmatch("[^\n]+") do
				table.insert(lines, line)
			end
			local vol    = tonumber(lines[1]) or 0
			local muted  = (lines[2] or "no") == "yes"
			local port   = lines[3] or "analog-output-speaker"
			local active = port:match("headphones") and "headphones" or "speakers"
			callback(vol, muted, active)
		end
	)
end

local function vol_icon(vol, muted)
	if muted or vol == 0 then return beautiful.icon_vol_mute end
	if vol < 33 then return "󰕿" end
	if vol < 66 then return beautiful.icon_vol_low end
	return beautiful.icon_vol_high
end

local icon_inner = wibox.widget({
	widget = wibox.widget.textbox,
	font   = beautiful.font_icon .. " " .. beautiful.fs_xl,
	markup = helpers.colorizeText(beautiful.icon_vol_high, beautiful.sky),
	align  = "center",
	valign = "center",
})

local icon_box = wibox.widget({
	{
		icon_inner,
		layout = wibox.layout.stack,
	},
	bg            = beautiful.bg_overlay,
	shape         = helpers.rrect(4),
	forced_width  = 48,
	forced_height = 48,
	widget        = wibox.container.background,
})

local title_w = wibox.widget({
	widget = wibox.widget.textbox,
	font   = beautiful.font .. " Medium " .. beautiful.fs_sm,
	markup = helpers.colorizeText("Volume", beautiful.text_base),
	valign = "center",
})

local sink_w = wibox.widget({
	widget = wibox.widget.textbox,
	font   = beautiful.font_mono .. " " .. beautiful.fs_xs,
	markup = helpers.colorizeText("No output", beautiful.text_dim),
	valign = "center",
})

local bar = wibox.widget({
	widget           = wibox.widget.progressbar,
	forced_height    = 1,
	shape            = helpers.rrect(999),
	bar_shape        = helpers.rrect(999),
	background_color = beautiful.bg_border,
	color            = beautiful.sky,
	value            = 0,
	max_value        = 100,
})

local pct_w = wibox.widget({
	widget       = wibox.widget.textbox,
	font         = beautiful.font_mono .. " " .. beautiful.fs_xs,
	markup       = helpers.colorizeText("0%", beautiful.text_base),
	align        = "right",
	valign       = "center",
	forced_width = 32,
})

local spk_dot = wibox.widget({
	forced_width  = 6,
	forced_height = 6,
	shape         = gears.shape.circle,
	bg            = beautiful.text_dim,
	widget        = wibox.container.background,
})

local spk_label = wibox.widget({
	widget = wibox.widget.textbox,
	font   = beautiful.font_mono .. " " .. beautiful.fs_xs,
	markup = helpers.colorizeText("Speakers", beautiful.text_muted),
	valign = "center",
})

local spk_box = wibox.widget({
	{
		{
			spk_dot,
			spk_label,
			spacing = 10,
			layout  = wibox.layout.fixed.horizontal,
		},
		layout = wibox.layout.align.horizontal,
	},
	margins = { left = 12, right = 12, top = 12, bottom = 12 },
	widget  = wibox.container.margin,
})

local spk_container = wibox.widget({
	spk_box,
	bg           = beautiful.bg_overlay,
	shape        = helpers.rrect(4),
	border_width = 1,
	border_color = "transparent",
	widget       = wibox.container.background,
})

local hdp_dot = wibox.widget({
	forced_width  = 6,
	forced_height = 6,
	shape         = gears.shape.circle,
	bg            = beautiful.text_dim,
	widget        = wibox.container.background,
})

local hdp_label = wibox.widget({
	widget = wibox.widget.textbox,
	font   = beautiful.font_mono .. " " .. beautiful.fs_xs,
	markup = helpers.colorizeText("Headphones", beautiful.text_muted),
	valign = "center",
})

local hdp_box = wibox.widget({
	{
		{
			hdp_dot,
			hdp_label,
			spacing = 6,
			layout  = wibox.layout.fixed.horizontal,
		},
		layout = wibox.layout.align.horizontal,
	},
	margins = { left = 12, right = 12, top = 12, bottom = 12 },
	widget  = wibox.container.margin,
})

local hdp_container = wibox.widget({
	hdp_box,
	bg           = beautiful.bg_overlay,
	shape        = helpers.rrect(4),
	border_width = 1,
	border_color = "transparent",
	widget       = wibox.container.background,
})

-- ── popup ──────────────────────────────────────
local popup = wibox({
	width        = WIDTH,
	height       = beautiful.notification_volume_height,
	visible      = false,
	ontop        = true,
	type         = "notification",
	bg           = beautiful.bg_raised,
	border_width = 1,
	border_color = beautiful.bg_border,
	shape        = helpers.rrect(beautiful.border_radius),
})

popup:setup({
	{
		{
			icon_box,
			wibox.container.constraint(
				wibox.widget({
					title_w,
					sink_w,
					spacing = 2,
					layout  = wibox.layout.fixed.vertical,
				}),
				"exact", WIDTH - 90
			),
			spacing = 12,
			layout  = wibox.layout.fixed.horizontal,
		},
		{
			{
				wibox.container.constraint(bar, "exact", WIDTH - 80),
				margins = { top = 6, bottom = 6, left = 0, right = 0 },
				widget = wibox.container.margin
			},
			pct_w,
			spacing = 8,
			layout  = wibox.layout.fixed.horizontal,
		},
		{
			spk_container,
			hdp_container,
			spacing = 6,
			layout  = wibox.layout.fixed.vertical,
		},
		spacing = 12,
		layout  = wibox.layout.fixed.vertical,
	},
	margins = { left = 14, right = 14, top = 14, bottom = 0 },
	widget  = wibox.container.margin,
})

awful.placement.top_right(popup, {
	margins = { top = beautiful.notification_volume_top, right = beautiful.notification_volume_right }
})

local function update_ui(vol, muted, active)
	icon_inner.markup          = helpers.colorizeText(
		vol_icon(vol, muted),
		muted and beautiful.terracotta or beautiful.sky)

	bar.value                  = vol
	bar.color                  = muted and beautiful.terracotta or beautiful.sky

	pct_w.markup               = helpers.colorizeText(
		muted and "mute" or (vol .. "%"),
		muted and beautiful.terracotta or beautiful.text_base)

	sink_w.markup              = helpers.colorizeText(
		"Analog Audio Output",
		beautiful.text_dim)

	spk_container.border_color = "transparent"
	hdp_container.border_color = "transparent"
	spk_dot.bg                 = beautiful.text_dim
	hdp_dot.bg                 = beautiful.text_dim
	spk_label.markup           = helpers.colorizeText("Speakers", beautiful.text_muted)
	hdp_label.markup           = helpers.colorizeText("Headphones", beautiful.text_muted)

	if active == "headphones" then
		hdp_container.border_color = beautiful.bg_border
		hdp_dot.bg                 = beautiful.sage
		hdp_label.markup           = helpers.colorizeText("Headphones", beautiful.text_base)
	else
		spk_container.border_color = beautiful.bg_border
		spk_dot.bg                 = beautiful.sage
		spk_label.markup           = helpers.colorizeText("Speakers", beautiful.text_base)
	end
end

-- ── show/hide ──────────────────────────────────
local function show()
	get_info(function(vol, muted, active)
		update_ui(vol, muted, active)
		popup.visible = true

		if hide_timer then hide_timer:stop() end
		hide_timer = gears.timer({
			timeout     = HIDE_DELAY,
			autostart   = true,
			single_shot = true,
			callback    = function()
				popup.visible = false
				hide_timer    = nil
			end,
		})
	end)
end

local function debounced_show()
	if update_timer then update_timer:stop() end
	update_timer = gears.timer({
		timeout     = 0.1,
		autostart   = true,
		single_shot = true,
		callback    = function()
			show()
			update_timer = nil
		end,
	})
end

-- ── public ─────────────────────────────────────
return {
	up = function(step)
		awful.spawn.with_shell(
			"pactl set-sink-volume @DEFAULT_SINK@ +" .. (step or 5) .. "%")
		debounced_show()
	end,
	down = function(step)
		awful.spawn.with_shell(
			"pactl set-sink-volume @DEFAULT_SINK@ -" .. (step or 5) .. "%")
		debounced_show()
	end,
	mute = function()
		awful.spawn.with_shell("pactl set-sink-mute @DEFAULT_SINK@ toggle")
		debounced_show()
	end,
	show = show,
}
