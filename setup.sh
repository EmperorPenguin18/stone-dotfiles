#!/bin/sh
#Make sure to be all updated and configured before starting

DISTRO=${1:-arch}
USER=${2:-alarm}

[ "$DISTRO" = "arch" ] && sudo pacman -S git base-devel xorg xorg-drivers xorg-xinit spectrwm termite ranger mpv nfs-utils xscreensaver unclutter --noconfirm --needed git clone https://aur.archlinux.org/pikaur.git cd pikaur && makepkg -si --noconfirm && pikaur -S xf86-input-joystick --noconfirm
echo 'if [ -z "${DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then' >> /home/$USER/"$(ls -a /home/$USER | grep profile)"
echo '  exec startx' >> /home/$USER/"$(ls -a /home/$USER | grep profile)"
echo 'fi' >> /home/$USER/"$(ls -a /home/$USER | grep profile)"
cp -f ./.xinitrc /home/$USER/
cp -f ./.spectrwm.conf /home/$USER/
mkdir -p /home/$USER/.config/mpv
cp -f ./mpv.conf /home/$USER/.config/mpv/
sudo echo '10.0.0.47:/mnt/MergerFS /mnt nfs rw' >> /etc/fstab
sudo mkdir -p /etc/X11/xorg.conf.d
sudo cp -f ./51-joystick.conf /etc/X11/xorg.conf.d/
sudo cp -f ./config.txt /boot/
sudo mkdir /etc/systemd/system/getty@tty1.service.d
sudo echo '[Service]' > /etc/systemd/system/getty@tty1.service.d/override.conf
sudo echo 'ExecStart=' >> /etc/systemd/system/getty@tty1.service.d/override.conf
sudo echo 'ExecStart=-/usr/bin/agetty --autologin alarm --noclear %I $TERM' >> /etc/systemd/system/getty@tty1.service.d/override.conf
