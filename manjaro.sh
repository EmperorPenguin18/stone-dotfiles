#!/bin/sh

dotfile ()
{
  mkdir -p "$2"
  cp -f "$DIR"/"$1" "$2"
  if file -i "$2$1" | grep shellscript >/dev/null; then
    chmod +x "$2$1"
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
DIR="/home/$USER/stone-dotfiles"

#Hardware acceleration
#pacman -S alsa-lib bzip2 fontconfig fribidi gmp gnutls gsm jack lame libass.so libavc1394 libbluray.so libcdio-paranoia libdav1d.so libdrm libfdk-aac libfreetype.so libiec61883 libmodplug libpulse libraw1394 libsoxr libssh libtheora libva.so libva-drm.so libva-x11.so libvdpau libvidstab.so libvorbisenc.so libvorbis.so libvpx.so libwebp libx11 libx264.so libx265.so libxcb libxext libxml2 libxv libxvidcore.so libzimg.so opencore-amr openjpeg2 opus sdl2 speex srt v4l-utils xz zlib amf-headers avisynthplus clang ladspa nasm --asdeps --noconfirm --needed
#su $USER -c "makepkg --noconfirm"
#pacman -U *.pkg* --noconfirm --needed

#Install packages
pacman -S xorg xorg-xinit spectrwm rxvt-unicode xsel alsa-utils file jq mediainfo xdotool w3m ffmpegthumbnailer mpv nfs-utils unclutter pyalpm python-commonmark go --noconfirm --needed
su $USER -c "git clone https://aur.archlinux.org/pikaur.git"
cd pikaur
su $USER -c "makepkg --noconfirm"
pacman -U *.pkg* --noconfirm --needed
cd ../
rm -r pikaur
su $USER -c "git clone https://aur.archlinux.org/xf86-input-joystick.git"
cd xf86-input-joystick
sed -i 's/arch=.*/arch=\(i686 x86_64 aarch64\)/g' PKGBUILD
sed -i "s/makedepends=.*/makedepends=\('xorg-server-devel' 'xorgproto'\)/g" PKGBUILD
sed -i '/conflicts/d' PKGBUILD
su $USER -c "makepkg --noconfirm --skippgpcheck"
pacman -U *.pkg* --noconfirm --needed
cd ../
rm -r xf86-input-joystick
install_aur all-repository-fonts lf

#Auto-login as user
dotfile "override.conf" "/etc/systemd/system/getty@tty1.service.d/"
sed -i "s/USER/$USER/g" /etc/systemd/system/getty@tty1.service.d/override.conf

#Auto-start X
echo 'if [ -z "${DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then' >> /home/$USER/"$(ls -a /home/$USER | grep profile)"
echo '  exec startx' >> /home/$USER/"$(ls -a /home/$USER | grep profile)"
echo 'fi' >> /home/$USER/"$(ls -a /home/$USER | grep profile)"

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

#Auto-mount nfs share
mkdir -p /media
echo '10.0.0.47:/mnt/MergerFS /media nfs rw,x-systemd.automount' >> /etc/fstab

#Clean up
chown -R $USER:$USER /home/$USER
