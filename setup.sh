#!/bin/sh

#sudo apt update -y && sudo apt upgrade -y
#sudo raspi-config
sudo apt install -y xorg xinit spectrwm ranger mediainfo mpv nfs-common xscreensaver
echo 'if [ -z "${DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then' >> /home/pi/"$(ls -a /home/pi | grep profile)"
echo '  exec startx' >> /home/pi/"$(ls -a /home/pi | grep profile)"
echo 'fi' >> /home/pi/"$(ls -a /home/pi | grep profile)"
cp -f .xinitrc /home/pi/
cp -f .spectrwm.conf /home/pi/
mkdir -p /home/pi/.config/mpv
cp -f mpv.conf /home/pi/.config/mpv/
sudo cp -f mediamount.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable mediamount
sudo apt install -y build-essential #
git clone --recursive https://github.com/Swordfish90/cool-retro-term.git
cd cool-retro-term
qmake && make
sudo mv cool-retro-term /usr/bin/
