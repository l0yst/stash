local awful = require("awful")

awful.spawn.with_shell([[
  xsetroot -cursor_name left_ptr
  xset r rate 200 50
  pactl set-default-sink effect_input.eq
  xrdb ~/.Xresources
  redshift -x && redshift -O 6500 -g 0.7 &
  pgrep -x picom        || picom &
  pgrep -x clipcatd     || clipcatd &
  pgrep -x polkit-gnome-authentication-agent-1 | /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
]])
