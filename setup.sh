#!/bin/sh

dotfile ()
{
  install -D $1 -t "$2"
  FILE="$(echo $(dirname $2)/$(basename -a $1) | head -1)"
  if file -i "$FILE" | grep shellscript >/dev/null; then
    chmod +x "$FILE"
  fi
  return 0
}

#Setup
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root"
  exit 1
fi
USER=$(ls /home)
DIR="/home/$USER/stone-dotfiles"
pacman -Sy git base-devel meson --noconfirm --needed
su $USER -c "git clone https://github.com/EmperorPenguin18/stone-dotfiles $DIR"
cd $DIR

#Install packages
pacman -S sway --noconfirm --needed

build_mesa ()
{
  pacman -S python-mako llvm wayland-protocols xorg-xrandr --asdeps --noconfirm --needed
  su $USER -c "git clone https://gitlab.freedesktop.org/mesa/mesa.git"
  cd mesa
  meson setup build -D b_ndebug=true -D b_lto=false -D platforms=x11,wayland -D gallium-drivers=swrast,v3d,vc4 -D dri3=enabled -D egl=enabled -D gbm=enabled -D gles1=disabled -D gles2=enabled -D glvnd=true -D glx=dri -D libunwind=enabled -D llvm=enabled -D lmsensors=enabled -D osmesa=true -D shared-glapi=enabled -D microsoft-clc=disabled -D valgrind=disabled -D tools=[] -D zstd=enabled -D video-codecs=vc1dec,h264dec,h264enc,h265dec,h265enc -D buildtype=plain --wrap-mode=nofallback -D prefix=/usr -D sysconfdir=/etc || exit 1
  meson configure --no-pager
  ninja $NINJAFLAGS -C build && \
  ninja $NINJAFLAGS -C build install && \
  rm -f /usr/bin/mesa-overlay-control.py && \
  ln -sf /usr/lib/libGLX_mesa.so.0 /usr/lib/libGLX_indirect.so.0 || \
  return 1
  cd ../ && return 0
}
build_mesa || exit 1 #Only needed until 23.1 releases

curl -sL http://mirror.archlinuxarm.org/aarch64/alarm/$(curl -sL http://mirror.archlinuxarm.org/aarch64/alarm/ | grep -m 1 "ffmpeg-rpi" | cut -f 2 -d '>' | cut -f 1 -d '<') > ffmpeg-rpi.pkg.tar.xz
pacman -U ffmpeg-rpi.pkg.tar.xz --asdeps --noconfirm --needed

build_mpv ()
{
  pacman -S sdl2 wireplumber pipewire-jack hicolor-icon-theme luajit wayland-protocols yt-dlp libass --asdeps --noconfirm --needed
  su $USER -c "git clone https://github.com/mpv-player/mpv"
  git config --global --add safe.directory $DIR/mpv
  cd mpv
  PKG_CONFIG_PATH=/usr/lib/ffmpeg-rpi/pkgconfig meson setup build -Dsdl2=enabled && ninja -C build && \
  ninja -C build install || \
  return 1
  cd ../ && return 0
}
build_mpv || exit 1 #Needed for the time being

#Auto-login as user
dotfile "$DIR/override.conf" "/etc/systemd/system/getty@tty1.service.d/"
sed -i "s/USER/$USER/g" /etc/systemd/system/getty@tty1.service.d/override.conf

#Auto-start Wayland
usermod -a -G seat $USER
systemctl enable seatd
PROFILE="$(ls -a /home/$USER | grep profile)"
echo 'if [ -z "${DISPLAY}" ] && [ "$(tty)" = "/dev/tty1" ]; then' >> /home/$USER/$PROFILE
echo '  exec sway' >> /home/$USER/$PROFILE
echo 'fi' >> /home/$USER/$PROFILE

#Config files
su $USER -c "git clone https://github.com/EmperorPenguin18/mpv-jellyfin /home/pi/.config/mpv"
dotfile "$DIR/mpv.conf" "/home/$USER/.config/mpv/"
dotfile "$DIR/input.conf" "/home/$USER/.config/mpv/"
dotfile "$DIR/config" "/home/$USER/.config/sway/"
su $USER -c "git clone https://github.com/johnodon/Transparent_Cursor_Theme $DIR/Transparent_Cursor_Theme"
dotfile "$DIR/Transparent_Cursor_Theme/Transparent/cursor.theme" "/usr/share/icons/Transparent/"
dotfile "$DIR/Transparent_Cursor_Theme/Transparent/cursors/*" "/usr/share/icons/Transparent/cursors/"

#Youtube
su $USER -c "git clone https://github.com/CogentRedTester/mpv-scroll-list $DIR/mpv-scroll-list"
dotfile "$DIR/mpv-scroll-list/scroll-list.lua" "/home/$USER/.config/mpv/script-modules/"
su $USER -c "git clone https://github.com/CogentRedTester/mpv-user-input $DIR/mpv-user-input"
dotfile "$DIR/mpv-user-input/user-input-module.lua" "/home/$USER/.config/mpv/script-modules/"
dotfile "$DIR/mpv-user-input/user-input.lua" "/home/$USER/.config/mpv/scripts/"
su $USER -c "git clone https://github.com/CogentRedTester/mpv-scripts $DIR/mpv-scripts"
dotfile "$DIR/mpv-scripts/youtube-search.lua" "/home/$USER/.config/mpv/scripts/"
dotfile "$DIR/youtube_search.conf" "/home/$USER/.config/mpv/script-opts/"

#Clean up
chown -R $USER:$USER /home/$USER
