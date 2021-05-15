#!/bin/sh

#First three steps of the instructions are replaced with the following:
#1. Install Arch for ARM following https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-4
#2. Perform the key init step as the root user (password root)
#3. Run the following commands as root:
#pacman -Syu
#reboot
#curl -sL https://raw.github.com/EmperorPenguin18/stone-dotfiles/main/arch.sh | sh

dotfile ()
{
  mkdir -p "$2"
  cp -f "$DIR"/"$1" "$2"
  if file -i "$2$1" | grep shellscript >/dev/null; then
    chmod +x "$2$1"
  fi
}

#Setup
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root"
  exit 1
fi
USER=${2:-alarm}
PASS1=$(dialog --stdout --passwordbox "Enter your password." 0 0)
PASS2=$(dialog --stdout --passwordbox "Confirm password." 0 0)
[ "$PASS1" != "$PASS2" ] && echo "Passwords do not match" && exit 1
HOST=$(dialog --stdout --inputbox "Enter your hostname." 0 0)
TIME=$(dialog --stdout --inputbox "Enter your timezone (eg America/Toronto)." 0 0)
pacman -Sy git base-devel --noconfirm --needed
su $USER -c "git clone https://github.com/EmperorPenguin18/stone-dotfiles /home/$USER/stone-dotfiles"
cd /home/$USER/stone-dotfiles
DIR="/home/$USER/stone-dotfiles"

#System configuration
printf "$PASS1\n$PASS1\n" | passwd
printf "$PASS1\n$PASS1\n" | passwd $USER
echo "$HOST" > /etc/hostname
ln -sf /usr/share/zoneinfo/$TIME /etc/localtime
timedatectl set-timezone $TIME

#Hardware acceleration
pacman -S alsa-lib bzip2 fontconfig fribidi gmp gnutls gsm jack lame libass.so libavc1394 libbluray.so libdav1d.so libdrm libfdk-aac libfreetype.so libiec61883 libmodplug libpulse libraw1394 libsoxr libssh libtheora libva.so libva-drm.so libva-x11.so libvdpau libvidstab.so libvorbisenc.so libvorbis.so libvpx.so libwebp libx11 libx264.so libx265.so libxcb libxext libxml2 libxv libxvidcore.so libzimg.so opencore-amr openjpeg2 opus sdl2 speex srt v4l-utils xz zlib amf-headers avisynthplus clang ladspa nasm --asdeps --noconfirm --needed
su $USER -c "makepkg --noconfirm"
pacman -U *.pkg* --noconfirm --needed

#Install packages
pacman -S xorg xorg-xinit spectrwm rxvt-unicode xsel alsa-utils ranger w3m ffmpegthumbnailer mpv nfs-utils unclutter pyalpm python-commonmark --noconfirm --needed
su $USER -c "git clone https://aur.archlinux.org/pikaur.git"
cd pikaur
su $USER -c "makepkg --noconfirm"
pacman -U *.pkg* --noconfirm --needed
cd ../
rm -r pikaur
pikaur -S xf86-input-joystick all-repository-fonts --noconfirm --mflags=--skippgpcheck

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
dotfile "51-joystick.conf" "/etc/X11/xorg.conf.d/"
dotfile "config.txt" "/boot"
su $USER -c "git clone https://github.com/muennich/urxvt-perls"
dotfile "urxvt-perls/keyboard-select" "/home/$USER/.urxvt/ext/"
dotfile "urxvt-perls/deprecated/clipboard" "/home/$USER/.urxvt/ext/"
dotfile "urxvt-perls/deprecated/url-select" "/home/$USER/.urxvt/ext/"
dotfile ".Xresources" "/home/$USER/"
dotfile "rc.conf" "/home/$USER/.config/ranger/"
dotfile "scope.sh" "/home/$USER/.config/ranger/"
dotfile "plugin_file_filter.py" "/home/$USER/.config/ranger/plugins/"

#Auto-mount nfs share
mkdir /mnt/Media
echo '10.0.0.47:/mnt/MergerFS /media nfs rw' >> /etc/fstab

#Clean up
chown -R $USER:$USER /home/$USER
