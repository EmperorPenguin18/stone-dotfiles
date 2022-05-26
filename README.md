# stone-dotfiles
Turns your Raspberry Pi into a minimal streaming box. Watch videos over a network share all controllable from the couch.

### How to use:
1. Install [Raspberry Pi OS Lite (64-bit)](https://www.raspberrypi.com/software/) to a storage device of at least 8GB. Plug that in to a Raspberry Pi 4 with cooling.
2. Boot up and enter your credentials.
3. Run the following commands:
```
sudo apt update
sudo apt dist-upgrade
reboot
sudo raspi-config
```
Settings to change:  
System -> Hostname (Optional)  
System -> Network at boot -> Yes  
Interface -> SSH -> Yes (Optional)  
Localisation -> Locale  
Localisation -> Timezone  
Localisation -> Keyboard  
Localisation -> WLAN Country
```
curl -sL https://raw.github.com/EmperorPenguin18/stone-dotfiles/main/debian.sh | sh
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
