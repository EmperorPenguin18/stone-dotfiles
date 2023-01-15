# stone-dotfiles
Turns your Raspberry Pi into a minimal Jellyfin client. Stream video files directly all controllable from the couch.

### How to use:
1. Install [Manjaro ARM Minimal (RPi 4)](https://manjaro.org/download/) to a micro SD card of at least 8GB. Plug that in to a Raspberry Pi 4 with cooling. Plug in a display, keyboard and optionally ethernet. If using Wi-Fi, SSID and password can be entered during setup.
2. Boot up and complete the setup.
3. Log in as the user you created. Run the following commands:
```
sudo pacman -Syu --noconfirm
sudo reboot
curl -sL https://raw.github.com/EmperorPenguin18/stone-dotfiles/main/setup.sh | sh
```
Enter your sudo password. This will take a while. Some stuff needs to be compiled.

4. The Jellyfin plugin is already installed, but needs to be configured according to https://github.com/EmperorPenguin18/mpv-jellyfin#configuration
5. Reboot. You should automatically enter into mpv (video player).
6. You can navigate Jellyfin and control mpv with a gamepad or keyboard (https://mpv.io/manual/master).
![alt text](https://raw.githubusercontent.com/EmperorPenguin18/stone-dotfiles/main/diagram.png)

Yes this is a JoJo reference.
