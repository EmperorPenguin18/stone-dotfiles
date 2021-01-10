#!/bin/sh

#sudo apt update -y && sudo apt upgrade -y
#sudo raspi-config
sudo apt install -y xorg xinit spectrwm ranger mediainfo mpv nfs-common xscreensaver unclutter snap
sudo snap install --classic cool-retro-term
echo 'if [ -z "${DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then' >> /home/pi/"$(ls -a /home/pi | grep profile)"
echo '  exec startx' >> /home/pi/"$(ls -a /home/pi | grep profile)"
echo 'fi' >> /home/pi/"$(ls -a /home/pi | grep profile)"
cp -f .xinitrc /home/pi/
cp -f .spectrwm.conf /home/pi/
mkdir -p /home/pi/.config/mpv
cp -f mpv.conf /home/pi/.config/mpv/
sudo echo '10.0.0.47:/mnt/MergerFS /mnt nfs rw' >> /etc/fstab
