#!/bin/sh

#Setup
USER=${1:-pi}
sudo apt install git
git clone https://github.com/EmperorPenguin18/stone-dotfiles
cd stone-dotfiles

#Get hardware decoding
#curl -s $(curl -s https://api.github.com/users/wildrun0/gists | grep raw_url | cut -f 4 -d '"') > compile-ffmpeg.sh
#chmod +x compile-ffmpeg.sh && ./compile-ffmpeg.sh

#Install packages
sudo apt install -y sway kitty file jq mediainfo golang imagemagick ffmpegthumbnailer mpv nfs-common
git clone https://github.com/AntiMicroX/antimicrox
sudo apt install -y cmake extra-cmake-modules qttools5-dev qttools5-dev-tools libsdl2-dev libxi-dev libxtst-dev libx11-dev itstool gettext
cd antimicrox
mkdir build && cd build
cmake .. -DCPACK_GENERATOR="DEB"
cmake --build . --target package
sudo dpkg -i antimicrox*.deb
env CGO_ENABLED=0 GO111MODULE=on go get -u -ldflags="-s -w" github.com/gokcehan/lf
sudo cp -f /home/$USER/go/bin/lf /usr/bin/
#pistol

#Auto-start X
PROFILE="$(ls -a /home/$USER | grep profile)"
echo 'if [ -z "${DISPLAY}" ] && [ "$(tty)" = "/dev/tty1" ]; then' >> /home/$USER/$PROFILE
echo '  exec sway' >> /home/$USER/$PROFILE
echo 'fi' >> /home/$USER/$PROFILE

#Config files
cp -f ./.xinitrc /home/$USER/
cp -f ./.spectrwm.conf /home/$USER/
mkdir -p /home/$USER/.config/mpv
cp -f ./mpv.conf /home/$USER/.config/mpv/
cp -f ./input.conf /home/$USER/.config/mpv/
sudo mkdir -p /etc/X11/xorg.conf.d
sudo cp -f ./51-joystick-mpv.conf /etc/X11/xorg.conf.d/
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
mkdir -p /home/$USER/.config/vlc
cp -f ./vlcrc /home/$USER/.config/vlc/vlcrc
mkdir -p /home/$USER/.config/lf
cp -f ./lfrc /home/$USER/.config/lf/
cp -f ./pv.sh /home/$USER/.config/lf/
chmod +x /home/$USER/.config/lf/pv.sh
cp -f ./draw_img.sh /home/$USER/.config/lf/
chmod +x /home/$USER/.config/lf/draw_img.sh
cp -f ./jellyfin.sh /home/$USER/jellyfin.sh
chmod +x /home/$USER/jellyfin.sh
mkdir -p /home/$USER/.config/sway
cp -f ./sway.txt /home/$USER/.config/sway/config
cp -f ./mpv.gamecontroller.amgp /home/$USER/
sudo cp -f ./uinput.service /etc/systemd/system/
sudo systemctl enable uinput

#Auto-mount nfs share
sudo mkdir -p /media
cat /etc/fstab > ./fstab
echo '10.0.0.47:/mnt/MergerFS /media nfs rw' >> ./fstab
sudo cp -f ./fstab /etc/
