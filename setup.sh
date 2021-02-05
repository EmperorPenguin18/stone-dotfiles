#!/bin/sh
#Make sure to be all updated and configured before starting

DISTRO=${1:-arch}
USER=${2:-alarm}

[ "$DISTRO" = "arch" ] && sudo pacman -S git base-devel xorg xorg-xinit spectrwm rxvt-unicode ranger mpv nfs-utils unclutter --noconfirm --needed && git clone https://aur.archlinux.org/pikaur.git && cd pikaur && makepkg -si --noconfirm && pikaur -S xf86-input-joystick --noconfirm
[ "$DISTRO" = "fedora" ] && sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm && sudo dnf install --assumeyes xorg-x11-server-Xorg xorg-x11-drv-fbdev xorg-x11-xinit spectrwm mesa* rxvt-unicode ranger mpv nfs-utils linuxconsoletools
[ "$DISTRO" = "debian" ] && sudo apt install -y #
echo 'if [ -z "${DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then' >> /home/$USER/"$(ls -a /home/$USER | grep profile)"
echo '  exec startx' >> /home/$USER/"$(ls -a /home/$USER | grep profile)"
echo 'fi' >> /home/$USER/"$(ls -a /home/$USER | grep profile)"
cp -f ./.xinitrc /home/$USER/
cp -f ./.spectrwm.conf /home/$USER/
mkdir -p /home/$USER/.config/mpv
cp -f ./mpv.conf /home/$USER/.config/mpv/
cat /etc/fstab > ./fstab
echo '10.0.0.47:/mnt/MergerFS /mnt nfs rw' >> ./fstab
sudo cp -f ./fstab /etc/
sudo mkdir -p /etc/X11/xorg.conf.d
sudo cp -f ./51-joystick.conf /etc/X11/xorg.conf.d/
[ "$DISTRO" != "fedora" ] && sudo cp -f ./config.txt /boot/
sudo mkdir /etc/systemd/system/getty@tty1.service.d
sudo cp -f ./override.conf /etc/systemd/system/getty@tty1.service.d/
sudo sed -i "s/USER/$USER/g" /etc/systemd/system/getty@tty1.service.d/override.conf

#https://addy-dclxvi.github.io/post/configuring-urxvt/
