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
pacman -S polkit xorg-xwayland sway ttf-inconsolata alsa-utils mpv nfs-utils --noconfirm --needed
install_aur antimicrox

#Build mpv
curl -sL http://mirror.archlinuxarm.org/aarch64/alarm/$(curl -sL http://mirror.archlinuxarm.org/aarch64/alarm/ | grep -m 1 "ffmpeg-rpi" | cut -f 2 -d '>' | cut -f 1 -d '<') > ffmpeg-rpi.pkg.tar.xz
pacman -U ffmpeg-rpi.pkg.tar.xz
git clone https://github.com/mpv-player/mpv && cd mpv
PKG_CONFIG_PATH=/usr/lib/ffmpeg-rpi/pkgconfig/ meson build && ninja -C build
cd ../

#Auto-login as user
dotfile "$DIR/override.conf" "/etc/systemd/system/getty@tty1.service.d/"
sed -i "s/USER/$USER/g" /etc/systemd/system/getty@tty1.service.d/override.conf

#Auto-start X
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

#Clean up
chown -R $USER:$USER /home/$USER
