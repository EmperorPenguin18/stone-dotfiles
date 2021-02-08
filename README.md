# stone-dotfiles
Configuration for Pi

Turns your Raspberry Pi into a streaming box. Watch videos over a network share all controllable from the couch.

### Known issues:
- No hardware acceleration (makes it pretty much unusable)

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
Settings to change:  
System -> Audio -> HDMI  
System -> Password  
System -> Hostname  
System -> Boot -> Console Autologin  
System -> Network at boot -> Yes  
Interface -> SSH -> Yes  
Localisation -> Locale  
Localisation -> Timezone  
Localisation -> Keyboard  
Localisation -> WLAN Country
```
sudo apt install git
git clone https://github.com/EmperorPenguin18/stone-dotfiles
cd stone-dotfiles
chmod +x setup.sh
./setup.sh
```
4. Change the line in /etc/fstab to mount your network share
5. Reboot. You should automatically enter into ranger (file manager).
6. You can navigate ranger and control mpv (video player) with a gamepad.
![alt text](https://raw.githubusercontent.com/EmperorPenguin18/stone-dotfiles/main/diagram.png)

### Future:
- Connect to Jellyfin
- Nicer interface

Yes this is a JoJo reference.
