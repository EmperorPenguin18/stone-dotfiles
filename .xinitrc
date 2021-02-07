xset s off -dpms
xrdb ~/.Xresources
amixer sset HDMI 100%
unclutter &
spectrwm &
exec urxvt -e ranger /mnt/Media
