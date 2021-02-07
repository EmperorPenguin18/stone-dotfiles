#!/bin/sh
#Make sure to be all updated and configured before starting, example:
#sudo apt update
#sudo apt dist-upgrade
#sudo rpi-update
#sudo raspi-config

DISTRO=${1:-debian}
USER=${2:-pi}

#Install packages
[ "$DISTRO" = "arch" ] && sudo pacman -S git base-devel xorg xorg-xinit spectrwm rxvt-unicode ranger mpv nfs-utils unclutter --noconfirm --needed && git clone https://aur.archlinux.org/pikaur.git && cd pikaur && makepkg -si --noconfirm && pikaur -S xf86-input-joystick --noconfirm
[ "$DISTRO" = "fedora" ] && sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm && sudo dnf install --assumeyes xorg-x11-server-Xorg xorg-x11-drv-fbdev xorg-x11-xinit spectrwm mesa* rxvt-unicode ranger mpv nfs-utils linuxconsoletools
[ "$DISTRO" = "debian" ] && sudo apt install -y xserver-xorg xinit libgles2-mesa libgles2-mesa-dev xorg-dev spectrwm rxvt-unicode xsel ranger mpv nfs-common unclutter xserver-xorg-input-joystick

#Auto-login as user
sudo mkdir /etc/systemd/system/getty@tty1.service.d
sudo cp -f ./override.conf /etc/systemd/system/getty@tty1.service.d/
sudo sed -i "s/USER/$USER/g" /etc/systemd/system/getty@tty1.service.d/override.conf

#Auto-start X
echo 'if [ -z "${DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then' >> /home/$USER/"$(ls -a /home/$USER | grep profile)"
echo '  exec startx' >> /home/$USER/"$(ls -a /home/$USER | grep profile)"
echo 'fi' >> /home/$USER/"$(ls -a /home/$USER | grep profile)"

#Config files
cp -f ./.xinitrc /home/$USER/
cp -f ./.spectrwm.conf /home/$USER/
mkdir -p /home/$USER/.config/mpv
cp -f ./mpv.conf /home/$USER/.config/mpv/
sudo mkdir -p /etc/X11/xorg.conf.d
sudo cp -f ./51-joystick.conf /etc/X11/xorg.conf.d/
[ "$DISTRO" != "fedora" ] && sudo cp -f ./config.txt /boot
git clone https://github.com/muennich/urxvt-perls
mkdir -p /home/$USER/.urxvt/ext
cp -f ./urxvt-perls/keyboard-select /home/$USER/.urxvt/ext/
cp -f ./urxvt-perls/deprecated/clipboard /home/$USER/.urxvt/ext/
cp -f ./urxvt-perls/deprecated/url-select /home/$USER/.urxvt/ext/
cp -f ./.Xresources /home/$USER/

#Auto-mount nfs share
cat /etc/fstab > ./fstab
echo '10.0.0.47:/mnt/MergerFS /mnt nfs rw' >> ./fstab
sudo cp -f ./fstab /etc/
