# Kiosk Pi

To run Raspberry Pi OS as a Kiosk device you need to setup auto login on the device first.

Update and install unclutter to hide the cursor.

```
sudo apt update
sudo apt -y dist-upgrade
sudo apt -y install unclutter
```
Create autostart file for your session.

```
cat <<EOF > ~/.config/lxsession/LXDE-pi/autostart
@lxpanel — profile LXDE-pi
@pcmanfm — desktop — profile LXDE-pi
#@xscreensaver -no-splash
@point-rpi
@xset -display :0 s off
@xset -display :0 s noblank
@xset -display :0 -dpms
unclutter &
EOF
```

If the Kiosk is meant to stay on 24/7 skip this step.

There are many ways to sleep and wake the Pi but I found `tvservice` to be the right answer because it terminates the HDMI output, allowing the monitor to actually sleep and save power.

Modify the sleep timing `0 19 * * *` (7 pm) and wake timing `30 8 * * *` (8.30 am).

```
sudo bash -c 'cat > /var/spool/cron/crontabs/pi' <<EOF
0 19 * * * /usr/bin/tvservice -p
30 8 * * 1-5 xset -display :0.0 dpms force on; xset -display :0.0 -dpms
EOF
```

For cron to trigger the sleep/wake commands at your local time ensure your timezone is set, otherwise timing is set UTC.

**Looping**

Another trick is to have the browser open in a loop so it will restart itself if something crashes it. Change the midori line if using another browser.

```
    while true; do
    midori -e Fullscreen -a https://some.domain
    done
```