#!/bin/bash

time=$(date +%Y-%m-%d-%H-%M-%S)
dir="$(xdg-user-dir PICTURES)/Screenshots"
file="Screenshot_${time}.png"

[[ ! -d "$dir" ]] && mkdir -p "$dir"


OPT1="<span foreground='#8bafc4'>  </span>  <span foreground='#c0c8cf'>Desktop</span>                                         <span foreground='#505a61'>capture full screen</span>"
OPT2="<span foreground='#a8c292'>  </span>  <span foreground='#c0c8cf'>Area</span>                                                         <span foreground='#505a61'>select region</span>"
OPT3="<span foreground='#8fc2ad'>  </span>  <span foreground='#c0c8cf'>Window</span>                                                 <span foreground='#505a61'>active window</span>"
OPT4="<span foreground='#c2bf88'>  </span>  <span foreground='#c0c8cf'>Delay 5s</span>                                     <span foreground='#505a61'>capture in 5 seconds</span>"
OPT5="<span foreground='#c4a98a'>  </span>  <span foreground='#c0c8cf'>Delay 10s</span>                                   <span foreground='#505a61'>capture in 10 seconds</span>"

copy_shot() {
    tee "$dir/$file" | xclip -selection clipboard -t image/png
}

notify_view() {
    if [[ -e "$dir/$file" ]]; then
        notify-send -a screenshot -u low "Screenshot Saved" "Saved to ~/Pictures/Screenshots/$file"
    else
        notify-send -a screenshot -u critical "Screenshot Failed" "Capture was deleted or failed"
    fi
}

countdown() {
    for sec in $(seq "$1" -1 1); do
        notify-send -a sceenshot -u low -t 1000 "Screenshot" "Taking shot in $sec..."
        sleep 1
    done
}

shotnow()  { sleep 0.5 && maim -u -f png | copy_shot; notify_view; }
shotarea() { maim -u -f png -s -b 2 -c 0.35,0.55,0.85,0.25 -l | copy_shot; notify_view; }
shotwin()  { maim -u -f png -i "$(xdotool getactivewindow)" | copy_shot; notify_view; }
shot5()    { countdown 5; sleep 1 && maim -u -f png | copy_shot; notify_view; }
shot10()   { countdown 10; sleep 1 && maim -u -f png | copy_shot; notify_view; }

# ------------------ Show Rofi menu ------------------
CHOSEN=$(printf "%s\n" "$OPT1" "$OPT2" "$OPT3" "$OPT4" "$OPT5" \
    | rofi -dmenu \
           -markup-rows \
           -theme ~/.config/rofi/layout/screenshoter.rasi \
           -p "")

# ------------------ Run chosen action ------------------
case "$CHOSEN" in
    *"Desktop"*)
        notify-send -a screenshot -u low "Screenshot" "Capturing full screen..."
        shotnow
        ;;
    *"Area"*)
        notify-send -a screenshot -u low "Screenshot" "Select a region to capture..."
        shotarea
        ;;
    *"Window"*)
        notify-send -a screenshot -u low "Screenshot" "Capturing active window..."
        shotwin
        ;;
    *"Delay 5s"*)
        shot5
        ;;
    *"Delay 10"*)
        shot10
        ;;
    *)
        notify-send -a screenshot -u low "Screenshot" "Cancelled"
        ;;
esac
