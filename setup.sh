#!/bin/sh

#sudo pacman -Syu
#sudo raspi-config
sudo pacman -S xorg xorg-drivers xorg-xinit spectrwm cool-retro-term ranger mediainfo mpv nfs-utils xscreensaver unclutter --noconfirm --needed
git clone https://aur.archlinux.org/pikaur.git
cd pikaur
makepkg -si --noconfirm
pikaur -S xf86-input-joystick
echo 'if [ -z "${DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then' >> /home/pi/"$(ls -a /home/pi | grep profile)"
echo '  exec startx' >> /home/pi/"$(ls -a /home/pi | grep profile)"
echo 'fi' >> /home/pi/"$(ls -a /home/pi | grep profile)"
cp -f .xinitrc /home/pi/
cp -f .spectrwm.conf /home/pi/
mkdir -p /home/pi/.config/mpv
cp -f mpv.conf /home/pi/.config/mpv/
sudo echo '10.0.0.47:/mnt/MergerFS /mnt nfs rw' >> /etc/fstab
sudo mkdir -p /etc/X11/xorg.conf.d
sudo cp -f 51-joystick.conf /etc/X11/xorg.conf.d/
