#!/bin/sh

#First three steps of the instructions are replaced with the following:
#1. Install Arch for ARM following https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-4
#2. Perform the key init step as the root user (password root)
#3. Run the following commands as root:
#pacman -Syu
#reboot
#curl -sL https://raw.github.com/EmperorPenguin18/stone-dotfiles/main/setup.sh | sh

USER=${2:-alarm}
PASS1=$(dialog --stdout --passwordbox "Enter your password." 0 0)
PASS2=$(dialog --stdout --passwordbox "Confirm password." 0 0)
[ "$PASS1" != "$PASS2" ] && echo "Passwords do not match" && exit 1
HOST=$(dialog --stdout --inputbox "Enter your hostname." 0 0)
TIME=$(dialog --stdout --inputbox "Enter your timezone (eg America/Toronto)." 0 0)

#Setup
pacman -Sy git base-devel
git clone https://github.com/EmperorPenguin18/stone-dotfiles /home/$USER/stone-dotfiles
cd /home/$USER/stone-dotfiles

#Configure stuff
printf "$PASS1\n$PASS1\n" | passwd
printf "$PASS1\n$PASS1\n" | passwd $USER
echo "$HOST" > /etc/hostname
ln -sf /usr/share/zoneinfo/$TIME /etc/localtime
timedatectl set-timezone $TIME

#Install packages
pacman -S xorg xorg-xinit spectrwm rxvt-unicode xsel alsa-utils ranger nfs-utils unclutter pyalpm python-commonmark --noconfirm --needed
su $USER -c "git clone https://aur.archlinux.org/pikaur.git"
cd pikaur
su $USER -c "makepkg --noconfirm"
pacman -U *.pkg* --noconfirm --needed
cd ../
rm -r pikaur
pikaur -S xf86-input-joystick --noconfirm

#Video stuff
su $USER -c "makepkg --noconfirm"
pacman -U *.pkg* --noconfirm --needed
pacman -S ffmpegthumbnailer mpv --noconfirm --needed

#Auto-login as user
mkdir /etc/systemd/system/getty@tty1.service.d
cp -f ./override.conf /etc/systemd/system/getty@tty1.service.d/
sed -i "s/USER/$USER/g" /etc/systemd/system/getty@tty1.service.d/override.conf

#Auto-start X
echo 'if [ -z "${DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then' >> /home/$USER/"$(ls -a /home/$USER | grep profile)"
echo '  exec startx' >> /home/$USER/"$(ls -a /home/$USER | grep profile)"
echo 'fi' >> /home/$USER/"$(ls -a /home/$USER | grep profile)"

#Config files
cp -f ./.xinitrc /home/$USER/
cp -f ./.spectrwm.conf /home/$USER/
mkdir -p /home/$USER/.config/mpv
cp -f ./mpv.conf /home/$USER/.config/mpv/
cp -f ./input.conf /home/$USER/.config/mpv/
mkdir -p /etc/X11/xorg.conf.d
cp -f ./51-joystick.conf /etc/X11/xorg.conf.d/
cp -f ./config.txt /boot
git clone https://github.com/muennich/urxvt-perls
mkdir -p /home/$USER/.urxvt/ext
cp -f ./urxvt-perls/keyboard-select /home/$USER/.urxvt/ext/
cp -f ./urxvt-perls/deprecated/clipboard /home/$USER/.urxvt/ext/
cp -f ./urxvt-perls/deprecated/url-select /home/$USER/.urxvt/ext/
cp -f ./.Xresources /home/$USER/
mkdir -p /home/$USER/.config/ranger/plugins
cp -f ./rc.conf /home/$USER/.config/ranger/
cp -f ./scope.sh /home/$USER/.config/ranger/
chmod +x /home/$USER/.config/ranger/scope.sh
cp -f ./plugin_file_filter.py /home/$USER/.config/ranger/plugins/

#Auto-mount nfs share
mkdir /mnt/Media
echo '10.0.0.47:/mnt/MergerFS /media nfs rw' >> /etc/fstab

#Clean up
chown -R $USER:$USER /home/$USER
