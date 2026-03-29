local key_menu = require("awful.hotkeys_popup")
local vol = require("ui.naughty.signals.volume")
local scratch = require("base.scratchpad")
local player = require("ui.naughty.signals.player")
local helpers = require("base.helpers")
local awful = require("awful")
local Home = os.getenv("HOME")
local Super = "Mod4"
local Alt = "Mod1"
local Shift = "Shift"
local Ctrl = "Control"

awful.keyboard.append_global_keybindings({

	-- Awesome
	awful.key({ Super }, "/", function()
		key_menu.show_help()
	end, { description = "Show keybinds", group = "Awesome" }),
	awful.key({ Super, Shift }, "r", awesome.restart, { description = "Restart Awesome", group = "Awesome" }),
	awful.key({ Super, Shift }, "q", awesome.quit, { description = "Quit awesome", group = "Awesome" }),

	-- --- Fuction Keys ---
	awful.key({ Super }, "F1", function()
		awful.spawn("spotify")
	end, { description = "Open spotify", group = "Apps" }),

	awful.key({ Super }, "F2", function()
		vol.down()
	end, { description = "Volume descrease", group = "Volume" }),

	awful.key({ Super }, "F3", function()
		vol.up()
	end, { description = "Volume  increase", group = "Volume" }),

	awful.key({ Super }, "F4", function()
		vol.mute()
	end, { description = "Volume mute", group = "Volume" }),

	-- play/pause
	awful.key({ Super }, "F5", function()
		player.prev()
	end, { description = "Play prev", group = "Player" }),
	awful.key({ Super }, "F6", function()
		player.next()
	end, { description = "Play next", group = "Player" }),
	awful.key({ Super }, "F7", function()
		player.play_pause()
	end, { description = "Play pause", group = "Player" }),
	awful.key({ Super }, "F8", function()
		player.stop()
	end, { description = "Stop", group = "Player" }),

	-- Apps
	awful.key({ Super }, "b", function()
		awful.spawn.with_shell(
			"zen-browser; rm -rf ~/.config/zen/*.Default\\ \\(release\\)/sessionstore-backups ~/.config/zen/*.Default\\ \\(release\\)/sessionCheckpoints.json ~/.config/zen/*.Default\\ \\(release\\)/sessionstore.jsonlz4 2>/dev/null"
		)
	end, { description = "Browser", group = "Apps" }),
	awful.key({ Super }, "f", function()
		awful.spawn("nautilus")
	end, { description = "File manager", group = "Apps" }),
	awful.key({ Super }, "m", function()
		awful.spawn("amberol")
	end, { description = "Music player", group = "Apps" }),
	awful.key({ Super }, "e", function()
		awful.spawn("zeditor")
	end, { description = "zed editor", group = "Apps" }),
	awful.key({ Super }, "h", function()
		awful.spawn("wezterm start -e htop")
	end, { description = "Monitor", group = "Apps" }),
	awful.key({ Super }, "n", function()
		awful.spawn("wezterm start -e nvim")
	end, { description = "neovim", group = "Apps" }),
	awful.key({ Super }, "Return", function()
		awful.spawn("wezterm")
	end, { description = "open terminal", group = "Apps" }),
	awful.key({ Super }, "grave", function()
		scratch.toggle()
	end, { description = "scratchpad terminal", group = "awesome" }),

	-- -- Rofi
	awful.key({ Super }, "a", function()
		awful.spawn("rofi -show drun -theme " .. Home .. "/.config/rofi/layout/apps.rasi")
	end, { description = "App launcher", group = "Rofi" }),

	awful.key({ Super }, "x", function()
		awful.spawn(Home .. "/.config/rofi/runners/powermenu.sh")
	end, { description = "Quit Applet", group = "Rofi" }),

	awful.key({ Super }, ",", function()
		awful.spawn("clipcat-menu")
	end, { description = "CLipboard Manager", group = "Rofi" }),

	awful.key({ Super }, ".", function()
		awful.spawn("rofimoji")
	end, { description = "Opn Emoji picker", group = "Rofi" }),

	awful.key({ Super }, "r", function()
		awful.spawn(Home .. "/.config/rofi/runners/appsroot.sh")
	end, { description = "Open apps as root", group = "Rofi" }),

	awful.key({}, "Print", function()
		awful.spawn(Home .. "/.config/rofi/runners/screenshoter.sh")
	end, { description = "Take Screenshot", group = "Rofi" }),

	-- Tags
	awful.key({ Super }, "Tab", awful.tag.viewnext, { description = "Jump to next tag", group = "Tags" }),
	awful.key({ Super, Shift }, "Tab", awful.tag.viewprev, { description = "Jump to prev tag", group = "Tags" }),

	-- Move window to left tag and follow (with wrapping)
	awful.key({ Super, Alt }, "Left", function()
		if client.focus then
			local c = client.focus
			local tag = c.first_tag
			local tag_index = tag.index
			local tags = c.screen.tags

			local new_index = tag_index == 1 and #tags or tag_index - 1
			local new_tag = tags[new_index]

			c:move_to_tag(new_tag)
			new_tag:view_only()
		end
	end, { description = "Move to previous tag and follow (loop)", group = "Tags" }),

	-- Move window to right tag and follow (with wrapping)
	awful.key({ Super, Alt }, "Right", function()
		if client.focus then
			local c = client.focus
			local tag = c.first_tag
			local tag_index = tag.index
			local tags = c.screen.tags

			local new_index = tag_index == #tags and 1 or tag_index + 1
			local new_tag = tags[new_index]

			c:move_to_tag(new_tag)
			new_tag:view_only()
		end
	end, { description = "Move to next tag and follow (loop)", group = "Tags" }),

	awful.key({
		modifiers = { Super },
		keygroup = "numrow",
		description = "Jump to tag",
		group = "Tags",
		on_press = function(index)
			local screen = awful.screen.focused()
			local tag = screen.tags[index]
			if tag then
				tag:view_only()
			end
		end,
	}),

	awful.key({
		modifiers = { Super, Shift },
		keygroup = "numrow",
		description = "Move window to tag",
		group = "Tags",
		on_press = function(index)
			if client.focus then
				local tag = client.focus.screen.tags[index]
				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end,
	}),

	-- Focus
	awful.key({ Super }, "Left", function()
		awful.client.focus.bydirection("left")
	end, { description = "Focus on left window", group = "Focus" }),
	awful.key({ Super }, "Right", function()
		awful.client.focus.bydirection("right")
	end, { description = "Focus on right window", group = "Focus" }),
	awful.key({ Super }, "Up", function()
		awful.client.focus.bydirection("up")
	end, { description = "Focus on up window", group = "Focus" }),
	awful.key({ Super }, "Down", function()
		awful.client.focus.bydirection("down")
	end, { description = "Focus on down window", group = "Focus" }),

	-- Swap
	awful.key({ Super, "Shift" }, "Down", function()
		awful.client.swap.bydirection("down", client.swap)
	end, { description = "Swap below window", group = "Windows" }),
	awful.key({ Super, "Shift" }, "Up", function()
		awful.client.swap.bydirection("up", client.swap)
	end, { description = "Swap above window", group = "Windows" }),
	awful.key({ Super, "Shift" }, "Left", function()
		awful.client.swap.bydirection("left", client.swap)
	end, { description = "Swap with left window", group = "Windows" }),
	awful.key({ Super, "Shift" }, "Right", function()
		awful.client.swap.bydirection("right", client.swap)
	end, { description = "Swap with right window", group = "Windows" }),

	-- Layouts
	awful.key({ Alt }, "Tab", function()
		awful.layout.inc(1)
	end, { description = "Cycle between layouts", group = "Layout" }),
	awful.key({ Alt, Shift }, "Tab", function()
		awful.layout.inc(-1)
	end, { description = "Revese between layouts", group = "Layout" }),
})

client.connect_signal("request::default_keybindings", function()
	awful.keyboard.append_client_keybindings({

		awful.key({ Super }, "c", function(c)
			c:kill()
		end, { description = "Kill, rend and slaughter your windows", group = "Awesome" }),

		awful.key({ Super, Shift }, "f", function(c)
			c.fullscreen = not c.fullscreen
			c:raise()
		end, { description = "Toggle fullscreen", group = "Awesome" }),

		awful.key({ Super, Shift }, "space", function(c)
			c.floating = not c.floating
			c:raise()
		end, { description = "Toggle floating", group = "Awesome" }),

		-- Resize
		awful.key({ Super, Ctrl }, "Up", function(c)
			helpers.resize_client(c, "up")
		end, { description = "Resize vertically -- up", group = "Windows" }),

		awful.key({ Super, Ctrl }, "Down", function(c)
			helpers.resize_client(c, "down")
		end, { description = "Resize vertically -- down", group = "Windows" }),

		awful.key({ Super, Ctrl }, "Left", function(c)
			helpers.resize_client(c, "left")
		end, { description = "Resize horizontally  -- left", group = "Windows" }),

		awful.key({ Super, Ctrl }, "Right", function(c)
			helpers.resize_client(c, "right")
		end, { description = "Resize horizontally -- right", group = "Windows" }),

		-- Stay on top (floating)

		awful.key({ Super, Shift }, "t", function(c)
			c.ontop = not c.ontop
		end, { description = "toggle keep on top", group = "client" }),
		-- Stick to all tags
		awful.key({ Super, Shift }, "s", function(c)
			c.sticky = not c.sticky
		end, { description = "toggle sticky (all tags)", group = "client" }),

		-- Move floating windows
		awful.key({ Ctrl, Shift }, "Up", function(c)
			if c.floating then
				c:relative_move(0, -20, 0, 0)
			end
		end, { description = "Move floating window up", group = "Windows" }),
		awful.key({ Ctrl, Shift }, "Down", function(c)
			if c.floating then
				c:relative_move(0, 20, 0, 0)
			end
		end, { description = "Move floating window down", group = "Windows" }),
		awful.key({ Ctrl, Shift }, "Left", function(c)
			if c.floating then
				c:relative_move(-20, 0, 0, 0)
			end
		end, { description = "Move floating window left", group = "Windows" }),
		awful.key({ Ctrl, Shift }, "Right", function(c)
			if c.floating then
				c:relative_move(20, 0, 0, 0)
			end
		end, { description = "Move floating window right", group = "Windows" }),
	})
end)

-- Mouse

client.connect_signal("request::default_mousebindings", function()
	awful.mouse.append_client_mousebindings({
		awful.button({}, 1, function(c)
			c:activate({ context = "mouse_click" })
		end),
		awful.button({ Super }, 1, function(c)
			c:activate({ context = "mouse_click", action = "mouse_move" })
		end),
		awful.button({ Super }, 3, function(c)
			c:activate({ context = "mouse_click", action = "mouse_resize" })
		end),
	})
end)
