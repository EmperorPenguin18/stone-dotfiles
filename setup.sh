#!/bin/sh

sudo apt update -y && sudo apt upgrade -y
sudo raspi-config
sudo apt install -y xorg xinit spectrwm cool-retro-term ranger mediainfo mpv nfs-common
cp -f .xinitrc /home/pi/
cp -f .spectrwm.conf /home/pi/
mkdir -p /home/pi/.config/mpv
cp -f mpv.conf /home/pi/.config/mpv/
