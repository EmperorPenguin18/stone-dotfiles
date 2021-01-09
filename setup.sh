#!/bin/sh

#sudo apt update -y && sudo apt upgrade -y
#sudo raspi-config
echo 'deb http://deb.xanmod.org releases main' | sudo tee /etc/apt/sources.list.d/xanmod-kernel.list && wget -qO - https://dl.xanmod.org/gpg.key | sudo apt-key add -
sudo apt update -y
sudo apt install -y linux-xanmod-edge xorg xinit spectrwm cool-retro-term ranger mediainfo mpv nfs-common xscreensaver
echo 'if [ -z "${DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then' > /home/pi/"$(ls -a /home/pi | grep profile)"
echo '  exec startx' >> /home/pi/"$(ls -a /home/pi | grep profile)"
echo 'fi' >> /home/pi/"$(ls -a /home/pi | grep profile)"
cp -f .xinitrc /home/pi/
cp -f .spectrwm.conf /home/pi/
mkdir -p /home/pi/.config/mpv
cp -f mpv.conf /home/pi/.config/mpv/
sudo cp -f mediamount.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable mediamount
