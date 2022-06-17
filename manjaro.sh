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
  for I in $@
  do
    su $USER -c "git clone https://aur.archlinux.org/$I.git /tmp/$I" && \
    OLD="$(pwd)" && \
    cd /tmp/$I && \
    DEPS=$(grep "depends=" PKGBUILD | sed "s/\"/'/g" | grep -o "'.*'" | sed "s/:.*'/'/g;s/'//g" | paste -sd " " -) && \
    pacman -S $DEPS --asdeps --noconfirm --needed && \
    su $USER -c "makepkg --noconfirm" && \
    pacman -U *.pkg* --noconfirm --needed && \
    cd $OLD || \
    return 1
  done
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
pacman -S polkit xorg-xwayland sway ttf-inconsolata kitty alsa-utils file jq mediainfo imagemagick ffmpegthumbnailer poppler mpv nfs-utils --noconfirm --needed
install_aur pandoc-bin lf antimicrox

#Auto-login as user
dotfile "$DIR/override.conf" "/etc/systemd/system/getty@tty1.service.d/"
sed -i "s/USER/$USER/g" /etc/systemd/system/getty@tty1.service.d/override.conf

#Auto-start X
PROFILE="$(ls -a /home/$USER | grep profile)"
echo 'if [ -z "${DISPLAY}" ] && [ "$(tty)" = "/dev/tty1" ]; then' >> /home/$USER/$PROFILE
echo '  exec sway' >> /home/$USER/$PROFILE
echo 'fi' >> /home/$USER/$PROFILE

#Config files
dotfile "$DIR/.xinitrc" "/home/$USER/"
dotfile "$DIR/.spectrwm.conf" "/home/$USER/"
dotfile "$DIR/mpv.conf" "/home/$USER/.config/mpv/"
dotfile "$DIR/input.conf" "/home/$USER/.config/mpv/"
dotfile "$DIR/51-joystick-mpv.conf" "/etc/X11/xorg.conf.d/"
su $USER -c "git clone https://github.com/muennich/urxvt-perls $DIR/urxvt-perls"
dotfile "$DIR/urxvt-perls/keyboard-select" "/home/$USER/.urxvt/ext/"
dotfile "$DIR/urxvt-perls/deprecated/clipboard" "/home/$USER/.urxvt/ext/"
dotfile "$DIR/urxvt-perls/deprecated/url-select" "/home/$USER/.urxvt/ext/"
dotfile "$DIR/.Xresources" "/home/$USER/"
dotfile "$DIR/rc.conf" "/home/$USER/.config/ranger/"
dotfile "$DIR/scope.sh" "/home/$USER/.config/ranger/"
dotfile "$DIR/plugin_file_filter.py" "/home/$USER/.config/ranger/plugins/"
dotfile "$DIR/vlcrc" "/home/$USER/.config/vlc/"
dotfile "$DIR/lfrc" "/home/$USER/.config/lf/"
dotfile "$DIR/pv.sh" "/home/$USER/.config/lf/"
dotfile "$DIR/draw_img.sh" "/home/$USER/.config/lf/"
dotfile "$DIR/jellyfin.sh" "/home/$USER/"
dotfile "$DIR/config" "/home/$USER/.config/sway/"
dotfile "$DIR/mpv.gamecontroller.amgp" "/home/$USER/"
dotfile "$DIR/uinput.service" "/etc/systemd/system/"
systemctl enable uinput
dotfile "$DIR/lf_kitty_preview" "/home/$USER/.config/lf/"
dotfile "$DIR/lf_kitty_clean" "/home/$USER/.config/lf/"
dotfile "$DIR/vidthumb" "/usr/bin/"
su $USER -c "git clone https://github.com/johnodon/Transparent_Cursor_Theme $DIR/Transparent_Cursor_Theme"
dotfile "$DIR/Transparent_Cursor_Theme/Transparent/cursor.theme" "/usr/share/icons/Transparent/"
dotfile "$DIR/Transparent_Cursor_Theme/Transparent/cursors/*" "/usr/share/icons/Transparent/cursors/"

#Auto-mount nfs share
mkdir -p /media
echo '10.0.0.47:/mnt/MergerFS /media nfs rw,nofail' >> /etc/fstab

#Clean up
chown -R $USER:$USER /home/$USER
