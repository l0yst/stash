#!/bin/bash

LOCK=""
SUSPEND=""
LOGOUT=""
REBOOT=""
SHUTDOWN="<span foreground='#c4a98a'></span>"
HIBERNATE="󰒲"

CHOSEN=$(printf "%s\n" \
    "$LOCK" "$HIBERNATE" "$LOGOUT" \
    "$REBOOT" "$SUSPEND" "$SHUTDOWN" \
    | rofi -dmenu \
           -markup-rows \
           -theme ~/.config/rofi/layout/powermenu.rasi \
           -u "3,5" \
           -p "")

case "$CHOSEN" in
    "$LOCK")      loginctl lock-session ;;
    "$SUSPEND")   systemctl suspend ;;
    "$LOGOUT")    loginctl terminate-session self ;;
    "$REBOOT")    sleep 1; systemctl reboot ;;
    "$HIBERNATE") systemctl hibernate ;;
    "$SHUTDOWN")  sleep 1; systemctl poweroff ;;
esac
