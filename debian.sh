#!/bin/sh

USER=${1:-pi}

#Get hardware decoding
curl -s $(curl -s https://api.github.com/users/wildrun0/gists | grep raw_url | cut -f 4 -d '"') > compile-ffmpeg.sh
chmod +x compile-ffmpeg.sh && ./compile-ffmpeg.sh
#

#Install packages
#sudo apt install -y xserver-xorg xinit libgles2-mesa libgles2-mesa-dev xorg-dev spectrwm rxvt-unicode xsel ranger ffmpegthumbnailer mpv nfs-common unclutter xserver-xorg-input-joystick xserver-xorg-input-all xinput
sudo apt install -y xserver-xorg xinit xorg-dev spectrwm rxvt-unicode xsel ranger ffmpegthumbnailer mpv nfs-common unclutter xserver-xorg-input-joystick xserver-xorg-input-all xinput

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
sudo mkdir -p /etc/X11/xorg.conf.d
sudo cp -f ./51-joystick.conf /etc/X11/xorg.conf.d/
sudo cp -f ./config.txt /boot
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
sudo mkdir /media
cat /etc/fstab > ./fstab
echo '10.0.0.47:/mnt/MergerFS /media nfs rw' >> ./fstab
sudo cp -f ./fstab /etc/
