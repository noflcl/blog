# Raspberry Pi

## General Pi

**i2c non root**

Add user to i2c group and create udev rule `/etc/udev/rules.d/50-i2c.rules`

`SUBSYSTEM=="i2c-dev", GROUP="i2c", MODE="0660"`

**Hangs On Boot**

If the rpi is hanging on boot with the message `random: crng init done`.

If running Pi headless at boot the kernel waits for mouse movements to initialize the random number generator.

Install and start haveged to solve this.

```
sudo apt -y install haveged
sudo systemctl enable haveged
```

### Manage WiFi

Check that the WiFi antenna isn't blocked.

`sudo rfkill list all`

To unblock your antenna use.

`sudo rfkill unblock 0`

**wpa_supplicant**

First kill all wpa_supplicant workers and then test your configuration file for errors.

Basic wpa_supplicant template `/etc/wpa_supplicant/wpa_supplicant.conf`

```
ctrl_interface=/var/run/wpa_supplicant GROUP=netdev
country=CA
update_config=1

network={
  scan_ssid=1
  ssid=""
  psk=""
}
```

`sudo killall wpa_supplicant`

Add `-d` flag on the end to make it more verbose

```
sudo wpa_supplicant -c/etc/wpa_supplicant/wpa_supplicant.conf -iwlan0
```



## Pi4

### USB Boot Issues

Some firmware in external USB enclosures can cause problems with booting. First step to resolving these issues is to install Raspberry Pi OS on a Micro SD card, boot, and `sudo apt update` & `sudo apt -y full-upgrade`. Any firmware upgrades will be performed by `rpi-eeprom-update` service and applied after next reboot. More information can be found at [boot eeprom](https://www.raspberrypi.org/documentation/hardware/raspberrypi/booteeprom.md) documentation.

**usb-storage.quirks**

Booted from your SD card without your external USB enclosure connected run `sudo dmesg -C`, now plug in the device and run `sudo dmesg`. The `idVendor` and `idProduct` are the two hexadecimal values you require.

Add these two values to the beginning of your `/boot/cmdline.txt` with `usb-storage.quirks`.

`usb-storage.quirks=aaaa:bbbb:u` <-- You must add the `:u` following your two values.

Reboot the system and check that quirks have been applied.

`dmesg | grep usb-storage`

### Bootloader and Conditional Filters
**Bootloader Config**

You can find the docs [here](https://www.raspberrypi.org/documentation/hardware/raspberrypi/bcm2711_bootloader_config.md).

**Conditional Filters**

You can find the docs [here](https://www.raspberrypi.org/documentation/configuration/config-txt/conditional.md).