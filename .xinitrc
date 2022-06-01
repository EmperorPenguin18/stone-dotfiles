xset s off -dpms
xrdb ~/.Xresources
amixer sset HDMI 100%
unclutter &
openbox &
exec kitty -e lf /media
