#!/bin/bash

NAUTILUS="<span foreground='#8fc2ad'>󰉋</span>  nautilus"
WEZTERM="<span foreground='#8bafc4'>󰆍</span>  wezterm"
ZEDITOR="<span foreground='#a699c4'>󰨞</span>  zeditor"

CHOSEN=$(printf "%s\n" \
    "$NAUTILUS" \
    "$WEZTERM" \
    "$ZEDITOR" \
    | rofi -dmenu \
           -markup-rows \
           -theme ~/.config/rofi/layout/appsroot.rasi \
           -p "")

run_cmd() {
    polkit_cmd="pkexec env PATH=$PATH DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS"
    if [[ "$1" == '--opt1' ]]; then
        nautilus admin:///
    elif [[ "$1" == '--opt2' ]]; then
        ${polkit_cmd} wezterm
    elif [[ "$1" == '--opt3' ]]; then
        ${polkit_cmd} env ZED_ALLOW_ROOT=true zeditor
    fi
}

case "$CHOSEN" in
    *"nautilus"*) run_cmd --opt1 ;;
    *"wezterm"*)  run_cmd --opt2 ;;
    *"zeditor"*)  run_cmd --opt3 ;;
esac
