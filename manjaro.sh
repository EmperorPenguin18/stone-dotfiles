#!/bin/sh

dotfile ()
{
  install -D "$1" -t "$2"
  FILE="$(dirname $2)/$(basename $1)"
  if file -i "$FILE" | grep shellscript >/dev/null; then
    chmod +x "$FILE"
  fi
  return 0
}

install_aur ()
{
  pikaur -S "$@" --noconfirm --needed --mflags=--skippgpcheck || return 1
  return 0
}

#Setup
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root"
  exit 1
fi
USER=$(ls /home)
pacman -Sy git base-devel --noconfirm --needed
su $USER -c "git clone https://github.com/EmperorPenguin18/stone-dotfiles /home/$USER/stone-dotfiles"
cd /home/$USER/stone-dotfiles

#Hardware acceleration
#pacman -S alsa-lib bzip2 fontconfig fribidi gmp gnutls gsm jack lame libass.so libavc1394 libbluray.so libcdio-paranoia libdav1d.so libdrm libfdk-aac libfreetype.so libiec61883 libmodplug libpulse libraw1394 libsoxr libssh libtheora libva.so libva-drm.so libva-x11.so libvdpau libvidstab.so libvorbisenc.so libvorbis.so libvpx.so libwebp libx11 libx264.so libx265.so libxcb libxext libxml2 libxv libxvidcore.so libzimg.so opencore-amr openjpeg2 opus sdl2 speex srt v4l-utils xz zlib amf-headers avisynthplus clang ladspa nasm --asdeps --noconfirm --needed
#su $USER -c "makepkg --noconfirm"
#pacman -U *.pkg* --noconfirm --needed

#Install packages
pacman -S sway kitty alsa-utils file jq mediainfo imagemagick ffmpegthumbnailer mpv nfs-utils pyalpm python-commonmark go --noconfirm --needed
su $USER -c "git clone https://aur.archlinux.org/pikaur.git"
cd pikaur
su $USER -c "makepkg --noconfirm"
pacman -U *.pkg* --noconfirm --needed
cd ../
rm -r pikaur
#su $USER -c "git clone https://aur.archlinux.org/xf86-input-joystick.git"
#cd xf86-input-joystick
#sed -i 's/arch=.*/arch=\(i686 x86_64 aarch64\)/g' PKGBUILD
#sed -i "s/makedepends=.*/makedepends=\('xorg-server-devel' 'xorgproto'\)/g" PKGBUILD
#sed -i '/conflicts/d' PKGBUILD
#su $USER -c "makepkg --noconfirm --skippgpcheck"
#pacman -U *.pkg* --noconfirm --needed
#cd ../
#rm -r xf86-input-joystick
install_aur all-repository-fonts lf antimicrox

#Auto-login as user
dotfile "override.conf" "/etc/systemd/system/getty@tty1.service.d/"
sed -i "s/USER/$USER/g" /etc/systemd/system/getty@tty1.service.d/override.conf

#Auto-start X
PROFILE="$(ls -a /home/$USER | grep profile)"
echo 'if [ -z "${DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then' >> /home/$USER/$PROFILE
echo '  exec sway' >> /home/$USER/$PROFILE
echo 'fi' >> /home/$USER/$PROFILE

#Config files
dotfile ".xinitrc" "/home/$USER/"
dotfile ".spectrwm.conf" "/home/$USER/"
dotfile "mpv.conf" "/home/$USER/.config/mpv/"
dotfile "input.conf" "/home/$USER/.config/mpv/"
dotfile "51-joystick-mpv.conf" "/etc/X11/xorg.conf.d/"
su $USER -c "git clone https://github.com/muennich/urxvt-perls"
dotfile "urxvt-perls/keyboard-select" "/home/$USER/.urxvt/ext/"
dotfile "urxvt-perls/deprecated/clipboard" "/home/$USER/.urxvt/ext/"
dotfile "urxvt-perls/deprecated/url-select" "/home/$USER/.urxvt/ext/"
dotfile ".Xresources" "/home/$USER/"
dotfile "rc.conf" "/home/$USER/.config/ranger/"
dotfile "scope.sh" "/home/$USER/.config/ranger/"
dotfile "plugin_file_filter.py" "/home/$USER/.config/ranger/plugins/"
dotfile "vlcrc" "/home/$USER/.config/vlc/"
dotfile "lfrc" "/home/$USER/.config/lf/"
dotfile "pv.sh" "/home/$USER/.config/lf/"
dotfile "draw_img.sh" "/home/$USER/.config/lf/"
dotfile "jellyfin.sh" "/home/$USER/"
dotfile "sway.txt" "/home/$USER/.config/sway/config"
dotfile "mpv.gamecontroller.amgp" "/home/$USER/"
#sudo cp -f ./uinput.service /etc/systemd/system/
#sudo systemctl enable uinput
dotfile "lf_kitty_preview" "/home/$USER/.config/lf/"
dotfile "lf_kitty_clean" "/home/$USER/.config/lf/"
dotfile "vidthumb" "/usr/bin/"
su $USER -c "git clone https://github.com/johnodon/Transparent_Cursor_Theme"
dotfile "Transparent_Cursor_Theme/Transparent/cursor.theme" "/usr/share/icons/Transparent/"
dotfile "Transparent_Cursor_Theme/Transparent/cursors/*" "/usr/share/icons/Transparent/cursors/"

#Auto-mount nfs share
mkdir -p /media
echo '10.0.0.47:/mnt/MergerFS /media nfs rw,x-systemd.automount' >> /etc/fstab

#Clean up
chown -R $USER:$USER /home/$USER
