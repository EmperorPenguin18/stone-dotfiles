# stone-dotfiles
Configuration for Pi

Turns your Raspberry Pi into a streaming box. Watch videos over a network share all controllable from the couch.

### How to use:
1. Install Raspberry Pi OS Lite (32-bit) to a Raspberry Pi of choice (Pi 4 with cooling recommended).
2. Boot up and log in (user: pi pass: raspberry).
3. Run the following commands:
```
sudo apt update
sudo apt dist-upgrade
sudo rpi-update
sudo reboot
sudo raspi-config
```

```
git clone https://github.com/EmperorPenguin18/stone-dotfiles
cd stone-dotfiles
chmod +x setup.sh
./setup.sh
```
4. Change the line in /etc/fstab to mount your network share
5. Reboot. You should automatically enter into ranger (file manager).
6. You can navigate and control mpv (video player) with a gamepad.
![alt text](https://raw.githubusercontent.com/EmperorPenguin18/stone-dotfiles/main/diagram.png)

Yes this is a JoJo reference.
