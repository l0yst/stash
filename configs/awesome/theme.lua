local theme = {}
local assets = os.getenv("HOME") .. "/.config/awesome/assets/"

-- ── colors ───────────────────────────────────────────────────
theme.bg = "#1c2023"
theme.bg_raised = "#252a2d"
theme.bg_overlay = "#2e3438"
theme.bg_border = "#3a4044"

-- text
theme.text_base = "#c0c8cf"
theme.text_muted = "#7a858e"
theme.text_dim = "#505a61"
theme.text_bright = "#dde2e6"

-- accents
theme.terracotta = "#c4a98a"
theme.sand = "#c2bf88"
theme.sage = "#a8c292"
theme.teal = "#8fc2ad"
theme.sky = "#8bafc4"
theme.lavender = "#a699c4"
theme.mauve = "#c294b2"
theme.rose = "#c49494"

-- ── fonts ────────────────────────────────────────────────────
theme.font = "DM Sans"
theme.font_mono = "JetBrains Mono"
theme.font_icon = "Symbols Nerd Font"

-- ── geometry ─────────────────────────────────────────────────
theme.useless_gap = 6
theme.screen_padding = 4
theme.border_width = 2
theme.border_radius = 8
theme.snap_border_width = 2
theme.snap_bg = theme.sage

-- ── borders ──────────────────────────────────────────────────
theme.border_normal = theme.bg_border
theme.border_focus = theme.sky
theme.border_marked = theme.sand
theme.border_urgent = theme.rose

-- ── bar ──────────────────────────────────────────────────────
theme.bar_height = 45
theme.bar_ratio = 0.70
theme.bar_margin = 8
theme.bar_radius = 8
theme.bar_border_width = 2
theme.vol_bar_width = 40
theme.vol_bar_height = 4

-- ── widget geometry ──────────────────────────────────────────
theme.widget_padding = 8
theme.widget_radius = 4
theme.widget_spacing = 14
theme.sep_height = 5
theme.sep_width = 1
theme.tags_spacing = 16

-- ── progress bars ───────────────────────────────────────────────
theme.p_bar_width = 200
theme.p_bar_height = 5

-- ── pill widget ──────────────────────────────────────────────
theme.pill_radius = 4
theme.pill_padding = 10

-- ── font sizes ───────────────────────────────────────────────
theme.fs_xs = 10
theme.fs_sm = 12
theme.fs_md = 14
theme.fs_lg = 16
theme.fs_xl = 18

-- ── icons ────────────────────────────────────────────────────
theme.icon_launcher = "󰣇"
theme.icon_wifi_on = "󰤨"
theme.icon_wifi_weak = "󰤢"
theme.icon_wifi_off = "󰤭"
theme.icon_vol_high = "󰕾"
theme.icon_vol_low = "󰖀"
theme.icon_vol_mute = "󰝟"
theme.icon_dnd = "󰂞"
theme.icon_tray = "󰇘"
theme.icon_layout_dwindle = "󰙀"
theme.icon_layout_float = "󰕬"
theme.icon_tag_focused = "󰮯"
theme.icon_tag_occupied = "󰊠"
theme.icon_tag_empty = "󰪥"
theme.icon_tag_urgent = "󰪟"
theme.redshift = "󰽥"
theme.mic = " 󰍬"
theme.gamemode = "󰺵"
theme.music = "󰽴"

-- ── bar colors ───────────────────────────────────────────────
theme.tag_focused = theme.rose
theme.tag_occupied = theme.sky
theme.tag_empty = theme.text_dim
theme.tag_urgent = theme.terracotta
theme.wifi_connected_fg = theme.sage
theme.wifi_weak_fg = theme.sand
theme.wifi_off_fg = theme.text_dim
theme.vol_high_fg = theme.sky
theme.vol_low_fg = theme.sand
theme.vol_mute_fg = theme.text_dim
theme.vol_bar_fg = theme.sky
theme.layout_fg = theme.lavender
theme.notif_fg = theme.text_muted
theme.notif_badge_fg = theme.terracotta
theme.tray_fg = theme.text_muted
theme.clock_fg = theme.text_base

-- ---dashbaord ---------------------------
theme.dashboard_bg = theme.bg_raised
theme.dashboard_radius = 12
theme.dashboard_width = 700
theme.dashboard_height = 420
theme.dashboard_x = 0
theme.dashboard_y = 20

theme.dashboard_user = "Loyst"
theme.weather_lat = "32.16"
theme.weather_lon = "74.18"

-- --- titlebars --------------------------
theme.titlebar_pos = "top"
theme.titlebar_height = 35
theme.circle_size = 12
theme.titlebar_color = theme.bg_raised
theme.close_color = theme.rose
theme.max_color = theme.sage
theme.ontop_color = theme.sky
theme.ontop_off = theme.lavender
theme.inactive_color = theme.text_dim
theme.tb_text_color = theme.text_muted
theme.tb_inactive_text_color = theme.text_dim

-- ── titlebar exclusions ───────────────────────────────────────
theme.titlebar_exclude_classes = { "vesktop", "steam" }
theme.titlebar_exclude_types = { "dialog", "utility", "splash", "notification" }

-- ── hotkeys popup ─────────────────────────────────────────────
theme.hotkeys_bg = theme.bg_raised
theme.hotkeys_fg = theme.text_base
theme.hotkeys_border_width = 1
theme.hotkeys_border_color = theme.bg_border
theme.hotkeys_shape = function(cr, w, h)
	require("gears").shape.rounded_rect(cr, w, h, theme.border_radius)
end
theme.hotkeys_modifiers_fg = theme.sky
theme.hotkeys_label_bg = theme.bg_overlay
theme.hotkeys_font = "JetBrains Mono Regular 10"
theme.hotkeys_description_font = "DM Sans Regular 11"
theme.hotkeys_group_margin = 12

-- ── notifications ─────────────────────────────────────────────
theme.notification_width = 420
theme.notification_height = 100
theme.notification_spacing = 15
theme.notification_timeout = 5
theme.notification_border_width = 1
theme.notification_border_color = theme.bg_border
theme.notification_font = "DM Sans Medium"
theme.notification_accent_width = 4
theme.notification_position = "bottom_right"

theme.notification_volume_width = 300
theme.notification_volume_height = 210
theme.notification_volume_right = 20
theme.notification_volume_top = 80
theme.notification_volume_delay = 3

-- ── wallpaper ────────────────────────────────────────────────
theme.wallpaper = assets .. "wallpapers/batman.jpg"
theme.pfp = assets .. "icons/pfp.png"

return theme
