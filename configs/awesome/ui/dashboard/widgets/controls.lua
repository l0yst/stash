local wibox = require("wibox")
local beautiful = require("beautiful")
local helpers = require("base.helpers")
local awful = require("awful")
local wifi_state = require("ui.bar.elements.wifi")
local naughty = require("naughty")

local label = wibox.widget({
	widget = wibox.widget.textbox,
	font = beautiful.font_mono .. " " .. beautiful.fs_xs,
	markup = helpers.colorizeText("CONTROLS", beautiful.text_dim),
	align = "left",
	valign = "center",
})

local function make_toggle(ico, text, color_on, color_off)
	local icon_w = wibox.widget({
		widget = wibox.widget.textbox,
		font = beautiful.font_icon .. " " .. beautiful.fs_md,
		markup = helpers.colorizeText(ico, color_off),
		align = "center",
		valign = "center",
	})
	local text_w = wibox.widget({
		widget = wibox.widget.textbox,
		font = "DM Sans Medium " .. beautiful.fs_xs,
		markup = helpers.colorizeText(text, beautiful.text_dim),
		align = "left",
		valign = "center",
	})
	local btn = wibox.widget({
		{
			helpers.pad(icon_w, 0, 0, 14, 0),
			text_w,
			layout = wibox.layout.fixed.horizontal,
			spacing = 10,
		},
		bg = beautiful.bg_overlay,
		shape = helpers.rrect(beautiful.widget_radius),
		border_width = beautiful.bar_border_width,
		border_color = beautiful.bg_border,
		forced_height = 50,
		forced_width = 300,
		widget = wibox.container.background,
	})

	local state = false
	local function set(on)
		state = on
		icon_w.markup = helpers.colorizeText(ico, on and color_on or color_off)
		btn.border_color = on and color_on or beautiful.bg_border
	end
	return btn, set, function()
		return state
	end, text_w
end

local wifi_btn, wifi_set, _, wifi_text = make_toggle(beautiful.icon_wifi_on, "Wifi", beautiful.sky, beautiful.text_dim)
local red_btn, red_set = make_toggle(beautiful.redshift, "Night Mode", beautiful.terracotta, beautiful.text_dim)
local mic_btn, mic_set = make_toggle(beautiful.mic, "Mic", beautiful.mauve, beautiful.text_dim)
local game_btn, game_set = make_toggle(beautiful.gamemode, "Game Mode", beautiful.teal, beautiful.text_dim)

local grid = wibox.widget({
	{ wifi_btn, red_btn, layout = wibox.layout.flex.horizontal, spacing = 8 },
	{ mic_btn, game_btn, layout = wibox.layout.flex.horizontal, spacing = 8 },
	layout = wibox.layout.fixed.vertical,
	spacing = 8,
})

local widget = wibox.widget({
	label,
	grid,
	layout = wibox.layout.fixed.vertical,
	spacing = 16,
})

-- ── WiFi ──────────────────────────────────────────────────────────────────
wifi_state.subscribe(function(state, ssid)
	if state == "connected" then
		wifi_set(true)
		wifi_text.markup = helpers.colorizeText(ssid ~= "" and ssid or "Wifi", beautiful.text_base)
	else
		wifi_set(false)
		wifi_text.markup = helpers.colorizeText("No Wifi", beautiful.text_dim)
	end
end)

helpers.onClick(wifi_btn, 1, wifi_state.toggle)

-- ── Redshift ──────────────────────────────────────────────────────────────
local redshift_on = false

helpers.onClick(red_btn, 1, function()
	redshift_on = not redshift_on
	local temp = redshift_on and "4500" or "6500"
	awful.spawn.with_shell("redshift -x && redshift -O " .. temp .. " -g 0.7")
	red_set(redshift_on)
	naughty.notify({ title = "Night Mode", message = redshift_on and "Enabled" or "Disabled", app_name = "redshift" })
end)

-- ------ mic ---------------------------

local mic_muted = false

local function fetch_mic_state()
	awful.spawn.with_shell("pactl get-source-mute @DEFAULT_SOURCE@ | grep -oP '(?<=Mute: )\\w+'", function(out)
		mic_muted = out:match("yes") ~= nil
		mic_set(not mic_muted)
	end)
end

helpers.onClick(mic_btn, 1, function()
	mic_muted = not mic_muted
	mic_set(not mic_muted)
	awful.spawn.with_shell("pactl set-source-mute @DEFAULT_SOURCE@ toggle")
	naughty.notify({ title = "Microphone", message = mic_muted and "Muted" or "Unmuted", app_name = "mic" })
end)

-- ── Game Mode ─────────────────────────────────────────────────────────────
local gamemode_on = false

helpers.onClick(game_btn, 1, function()
	gamemode_on = not gamemode_on
	local mode = gamemode_on and "on" or "off"
	awful.spawn.with_shell("sudo ~/stash/scripts/ultimate-mode.sh " .. mode)
	game_set(gamemode_on)
end)

function widget.refresh()
	fetch_mic_state()
end

return widget
