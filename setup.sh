#!/bin/sh

#sudo apt update -y && sudo apt upgrade -y
#sudo raspi-config
echo 'deb http://deb.xanmod.org releases main' | tee /etc/apt/sources.list.d/xanmod-kernel.list && wget -qO - https://dl.xanmod.org/gpg.key | apt-key add -
sudo apt update -y
sudo apt install -y linux-xanmod-edge xorg xinit spectrwm cool-retro-term ranger mediainfo mpv nfs-common xscreensaver
echo 'if [ -z "${DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then' > "$(ls -a /home/pi | grep profile)"
echo '  exec startx' >> "$(ls -a /home/pi | grep profile)"
echo 'fi' >> "$(ls -a /home/pi | grep profile)"
cp -f .xinitrc /home/pi/
cp -f .spectrwm.conf /home/pi/
mkdir -p /home/pi/.config/mpv
cp -f mpv.conf /home/pi/.config/mpv/
sudo chown -R pi:pi /mnt
sudo cp -f mediamount.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable mediamount
