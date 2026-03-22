#!/bin/bash

# ROOT CHECK
if [ "$EUID" -ne 0 ]; then
    echo "Error: Run with sudo"
    exit 1
fi

# DETECT REAL USER
REAL_USER=$(logname)
REAL_UID=$(id -u "$REAL_USER")

# FUNCTION TO SEND NOTIFICATION
send_notify() {
    local title="$1"
    local msg="$2"
    # Use sudo -u + DBUS path
    sudo -u "$REAL_USER" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$REAL_UID/bus" \
        notify-send -a power -u low "$title" "$msg"
}

# POWER MODE LOGIC
case "$1" in
on)
    echo "Enabling ULTIMATE POWER mode..."

    killall picom
    killall clipcatd
    systemctl stop libvirtd
    pkill gvfsd

    # GPU
    echo high >/sys/class/drm/card1/device/power_dpm_force_performance_level
    echo performance >/sys/class/drm/card1/device/power_dpm_state

    # CPU
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo performance >"$cpu"
    done

    echo "System is now at MAX performance."

    send_notify "Ultimate Performance ON" "Ultimate power mode has been turned on"
    ;;

off)
    echo "Restoring balanced mode..."

    sudo -u "$REAL_USER" picom &
    sudo -u "$REAL_USER" clipcatd &
    systemctl start libvirtd

    # GPU
    echo auto >/sys/class/drm/card1/device/power_dpm_force_performance_level
    echo balanced >/sys/class/drm/card1/device/power_dpm_state

    # CPU
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo schedutil >"$cpu"
    done

    echo "System restored to balanced mode."

    send_notify "Ultimate Performance OFF" "Ultimate power mode has been turned off"
    ;;

*)
    echo "Usage: sudo $0 [on|off]"
    exit 1
    ;;
esac
