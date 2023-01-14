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

install_aur ()
{
  OLD="$(pwd)"
  for I in $@
  do
    su $USER -c "git clone https://aur.archlinux.org/$I.git /tmp/$I" && \
    cd /tmp/$I && \
    DEPS=$(grep "depends=" PKGBUILD | sed "s/\"/'/g" | grep -o "'.*'" | sed "s/:.*'/'/g;s/'//g" | paste -sd " " -) && \
    pacman -S $DEPS --asdeps --noconfirm --needed && \
    su $USER -c "makepkg --noconfirm" && \
    pacman -U *.pkg* --noconfirm --needed || \
    return 1
  done
  cd $OLD
  return 0
}

#Setup
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root"
  exit 1
fi
USER=$(ls /home)
DIR="/home/$USER/stone-dotfiles"
pacman -Sy git base-devel --noconfirm --needed
su $USER -c "git clone https://github.com/EmperorPenguin18/stone-dotfiles $DIR"
cd $DIR

#Install packages
pacman -S xorg-xwayland sway --noconfirm --needed
install_aur antimicrox

build_mesa ()
{
  su $USER -c "git clone --branch dev/pi_drm_format https://gitlab.freedesktop.org/EmperorPenguin18/mesa.git"
  cd mesa
  meson setup build -D b_ndebug=true -D b_lto=false -D platforms=x11,wayland -D gallium-drivers=swrast,v3d,vc4 -D dri3=enabled -D egl=enabled -D gbm=enabled -D gles1=disabled -D gles2=enabled -D glvnd=true -D glx=dri -D libunwind=enabled -D llvm=enabled -D lmsensors=enabled -D osmesa=true -D shared-glapi=enabled -D microsoft-clc=disabled -D valgrind=disabled -D tools=[] -D zstd=enabled -D video-codecs=vc1dec,h264dec,h264enc,h265dec,h265enc -D buildtype=plain --wrap-mode=nofallback -D prefix=/usr -D sysconfdir=/etc || exit 1
  meson configure --no-pager
  ninja $NINJAFLAGS -C build && \
  ninja $NINJAFLAGS -C build install && \
  rm -f /usr/bin/mesa-overlay-control.py && \
  ln -sf /usr/lib/libGLX_mesa.so.0 /usr/lib/libGLX_indirect.so.0 || \
  exit 1
  cd ../
}
build_mesa #Only needed until 23.0 releases

build_ffmpeg ()
{
  su $USER -c "git clone --branch dev/5.1.2/rpi_import_1 https://github.com/EmperorPenguin18/rpi-ffmpeg"
  cd rpi-ffmpeg
  CFLAGS="-march=native -mtune=native" CXXFLAGS="-march=native -mtune=native" ./configure --prefix=/usr --disable-network --disable-debug --disable-muxers --disable-indevs --disable-outdev=fbdev --disable-outdev=oss --disable-doc --disable-bsfs --disable-ffprobe --disable-sdl2 --disable-stripping --disable-thumb --disable-mmal --enable-sand --enable-v4l2-request --enable-libdrm --enable-epoxy --enable-libudev --enable-vout-drm
  make install
  cd ../
}
build_ffmpeg #Needed for the time being

build_mpv ()
{
  pacman -S wireplumber pipewire-jack hicolor-icon-theme luajit wayland-protocols yt-dlp --asdeps --noconfirm --needed
  su $USER -c "git clone --branch pi_h265 https://github.com/EmperorPenguin18/mpv" && cd mpv
  meson build && ninja -C build
  dotfile "./build/mpv" "/usr/bin/" && cd ../
}
build_mpv #Needed for the time being

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
dotfile "$DIR/mpv.conf" "/home/$USER/.config/mpv/"
dotfile "$DIR/input.conf" "/home/$USER/.config/mpv/"
dotfile "$DIR/config" "/home/$USER/.config/sway/"
dotfile "$DIR/mpv.gamecontroller.amgp" "/home/$USER/"
dotfile "$DIR/uinput.service" "/etc/systemd/system/"
systemctl enable uinput
su $USER -c "git clone https://github.com/johnodon/Transparent_Cursor_Theme $DIR/Transparent_Cursor_Theme"
dotfile "$DIR/Transparent_Cursor_Theme/Transparent/cursor.theme" "/usr/share/icons/Transparent/"
dotfile "$DIR/Transparent_Cursor_Theme/Transparent/cursors/*" "/usr/share/icons/Transparent/cursors/"
su $USER -c "git clone https://github.com/EmperorPenguin18/mpv-jellyfin /home/pi/.config/mpv"
DEFAULT=$(wpctl status | grep -m 1 'HDMI' | awk '{print $3}' | cut -f 1 -d '.')
wpctl set-default $DEFAULT
wpctl set-mute $DEFAULT 0
wpctl set-volume $DEFAULT 100%

#Youtube
su $USER -c "git clone https://github.com/CogentRedTester/mpv-scroll-list"
dotfile "$DIR/mpv-scroll-list/scroll-list.lua" "/home/$USER/.config/mpv/script-modules/"
su $USER -c "git clone https://github.com/CogentRedTester/mpv-user-input"
dotfile "$DIR/mpv-user-input/user-input-module.lua" "/home/$USER/.config/mpv/script-modules/"
dotfile "$DIR/mpv-user-input/user-input.lua" "/home/$USER/.config/mpv/scripts/"
su $USER -c "git clone https://github.com/CogentRedTester/mpv-scripts"
dotfile "$DIR/mpv-scripts/youtube-search.lua" "/home/$USER/.config/mpv/scripts/"
dotfile "$DIR/youtube.conf" "/home/$USER/.config/mpv/script-opts/"

#Clean up
chown -R $USER:$USER /home/$USER
