# stone-dotfiles
Turns your Raspberry Pi into a minimal streaming box. Watch videos over a network share all controllable from the couch.

### How to use:
1. Install [Manjaro ARM Minimal (RPi 4)](https://manjaro.org/download/) to a micro SD card of at least 8GB. Plug that in to a Raspberry Pi 4 with cooling. Plug in a display, keyboard and optionally ethernet. If using Wi-Fi, SSID and password can be entered during setup.
2. Boot up and complete the setup.
3. Log in as root. Run the following commands:
```
pacman -Syu --noconfirm
reboot
curl -sL https://raw.github.com/EmperorPenguin18/stone-dotfiles/main/manjaro.sh | sh
```
This will take a while. There's lots of software to install.

4. Change the line in /etc/fstab to mount your network share
5. Input your credentials into jellyfin.sh
6. Reboot. You should automatically enter into lf (file viewer).
7. You can navigate lf and control mpv (video player) with a gamepad.
![alt text](https://raw.githubusercontent.com/EmperorPenguin18/stone-dotfiles/main/diagram.png)

### Future:
- Nicer interface
- Improve font selection (Japanese characters)

Yes this is a JoJo reference.
