local wibox = require("wibox")
local beautiful = require("beautiful")
local helpers = require("base.helpers")
local naughty = require("naughty")
local lgi = require("lgi")
local Gio = lgi.Gio
local IWD_SERVICE = "net.connman.iwd"
local bus = Gio.bus_get_sync(Gio.BusType.SYSTEM)

local stations = {}
local current_station = nil
local current_state = "disconnected"
local current_ssid = ""
local callbacks = {}
local last_network_path = nil
local function emit()
	for _, cb in ipairs(callbacks) do
		cb(current_state, current_ssid)
	end
end

local function set_state(state, ssid)
	current_state = state or "disconnected"
	current_ssid = ssid or ""
	emit()
end

local function update_station(proxy, path)
	local state_var = proxy:get_cached_property("State")
	if not state_var then
		return
	end

	local state = state_var.value

	if state == "connected" then
		current_station = path

		local net_var = proxy:get_cached_property("ConnectedNetwork")
		if net_var and net_var.value ~= "/" then
			last_network_path = net_var.value
			local net_proxy =
				Gio.DBusProxy.new_sync(bus, 0, nil, IWD_SERVICE, net_var.value, "net.connman.iwd.Network", nil)

			local name_var = net_proxy:get_cached_property("Name")
			set_state("connected", name_var and name_var.value or "")
		else
			set_state("connected", "")
		end
	else
		if current_station == path then
			current_station = nil
			set_state("disconnected", "")
		end
	end
end

local function attach_station(path)
	if stations[path] then
		return
	end

	local proxy = Gio.DBusProxy.new_sync(bus, 0, nil, IWD_SERVICE, path, "net.connman.iwd.Station", nil)

	stations[path] = proxy

	proxy.on_g_properties_changed = function()
		update_station(proxy, path)
	end

	update_station(proxy, path)
end

local manager = Gio.DBusProxy.new_sync(bus, 0, nil, IWD_SERVICE, "/", "org.freedesktop.DBus.ObjectManager", nil)

local result = manager:call_sync("GetManagedObjects", nil, 0, -1, nil)

local objects = result:get_child_value(0)

for i = 0, objects:n_children() - 1 do
	local entry = objects:get_child_value(i)
	local path = entry:get_child_value(0).value
	local ifaces = entry:get_child_value(1)

	for j = 0, ifaces:n_children() - 1 do
		local iface_entry = ifaces:get_child_value(j)
		local iface_name = iface_entry:get_child_value(0).value

		if iface_name == "net.connman.iwd.Station" then
			attach_station(path)
		end
	end
end

manager.on_g_signal = function(_, _, signal, params)
	if signal == "InterfacesAdded" or signal == "InterfacesRemoved" then
		local result = manager:call_sync("GetManagedObjects", nil, 0, -1, nil)
		local objects = result:get_child_value(0)

		for i = 0, objects:n_children() - 1 do
			local entry = objects:get_child_value(i)
			local path = entry:get_child_value(0).value
			local ifaces = entry:get_child_value(1)

			for j = 0, ifaces:n_children() - 1 do
				local iface_entry = ifaces:get_child_value(j)
				local iface_name = iface_entry:get_child_value(0).value

				if iface_name == "net.connman.iwd.Station" then
					attach_station(path)
				end
			end
		end

		if signal == "InterfacesRemoved" then
			local path = params:get_child_value(0).value
			stations[path] = nil
			if current_station == path then
				current_station = nil
				set_state("disconnected", "")
			end
		end
	end
end

local icon = wibox.widget({
	widget = wibox.widget.textbox,
	font = beautiful.font_icon .. " " .. beautiful.fs_md,
	align = "center",
	valign = "center",
})

local function update_icon(state)
	if state == "connected" then
		icon.markup = helpers.colorizeText(beautiful.icon_wifi_on, beautiful.wifi_connected_fg)
	elseif state == "connecting" then
		icon.markup = helpers.colorizeText(beautiful.icon_wifi_weak, beautiful.wifi_weak_fg)
	else
		icon.markup = helpers.colorizeText(beautiful.icon_wifi_off, beautiful.wifi_off_fg)
		naughty.notify({ title = "Wifi", message = "Wifi has been disconnected", app_name = "network" })
	end
end

local widget = wibox.widget({
	icon,
	bg = "transparent",
	widget = wibox.container.background,
})

function widget.subscribe(cb)
	table.insert(callbacks, cb)
	cb(current_state, current_ssid)
end

function widget.toggle()
	if current_state == "connected" then
		if current_station and stations[current_station] then
			stations[current_station]:call_sync("Disconnect", nil, 0, -1, nil)
		end
	else
		if last_network_path then
			local net_proxy =
				Gio.DBusProxy.new_sync(bus, 0, nil, IWD_SERVICE, last_network_path, "net.connman.iwd.Network", nil)
			net_proxy:call_sync("Connect", nil, 0, -1, nil)
		else
			naughty.notify({ title = "WiFi", text = "No known network to reconnect to!", app_name = "network" })
		end
	end
end

widget.subscribe(function(state)
	update_icon(state)
end)

return widget
