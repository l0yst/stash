local awful = require("awful")
local beautiful = require("beautiful")

awful.rules.rules = {

	{
		rule = {},
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen,
			raise = true,
			size_hints_honor = false,
		},
	},

	{
		rule_any = { type = { "dock", "desktop" } },
		properties = {
			border_width = 0,
		},
	},

	{
		rule = { class = "zen" },
		properties = {
			maximized = false,
			floating = false,
			ontop = false,
		},
	},

	{
		rule = { class = "stremio-enhanced" },
		properties = {
			maximized = true,
		},
	},

	{
		rule = { class = "qView" },
		properties = {
			floating = true,
			placement = awful.placement.centered,
		},
	},
	{
		rule = { class = "vesktop" },
		properties = {
			placement = awful.placement.centered,
		},
	},
	{
		rule = { class = "org.gnome.FileRoller" },
		properties = {
			floating = true,
			placement = awful.placement.centered,
		},
	},

	{
		rule = { class = "Gpick" },
		properties = {
			floating = true,
			placement = awful.placement.centered,
		},
	},
	{
		rule = { class = "gnome-calculator" },
		properties = {
			floating = true,
			placement = awful.placement.centered,
		},
	},

	{
		rule_any = { type = { "dialog" } },
		properties = {
			floating = true,
			placement = awful.placement.centered,
		},
	},
}
