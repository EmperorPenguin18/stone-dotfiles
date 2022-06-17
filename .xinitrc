xset s off -dpms
xrdb ~/.Xresources
amixer sset PCM 100%
unclutter &
openbox &
LIBGL_ALWAYS_SOFTWARE=1 exec kitty -e lf /media
