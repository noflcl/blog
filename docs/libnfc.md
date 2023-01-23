# libnfc

This may be a bit outdated but should be simple to update. Compile and install libnfc for use with NFC device.

Enable I2C with raspi-config or in `/etc/modules`.

`sudo apt -y install libusb-dev libpcsclite-dev i2c-tools`

```
cd ~
mkdir nfc && cd nfc
Download latest libnfc
https://github.com/nfc-tools/libnfc/releases/
wget https://github.com/nfc-tools/libnfc/releases/download/libnfc-1.7.1/libnfc-1.7.1.tar.bz2

tar -xvjf libnfc*
cd libnfc*
sudo mkdir -p /etc/nfc/devices.d
```

Compile

```
./configure --prefix=/usr --sysconfdir=/etc
make
sudo make install
```

In `/etc/nfc/libnfc.conf`

Add the following:

```
# Allow device auto-detection (default: true)
# Note: if this auto-detection is disabled, user has to set manually a device
# configuration using file or environment variable
allow_autoscan = true

# Allow intrusive auto-detection (default: false)
# Warning: intrusive auto-detection can seriously disturb other devices
# This option is not recommended, user should prefer to add manually his device.
allow_intrusive_scan = false

# Set log level (default: error)
# Valid log levels are (in order of verbosity): 0 (none), 1 (error), 2 (info), 3 (debug)
# Note: if you compiled with --enable-debug option, the default log level is "debug"
log_level = 1

# Manually set default device (no default)
# To set a default device, you must set both name and connstring for your device
# Note: if autoscan is enabled, default device will be the first device available in device list.
#device.name = "_PN532_SPI"
#device.connstring = "pn532_spi:/dev/spidev0.0:500000"
device.name = "_PN532_I2c"
device.connstring = "pn532_i2c:/dev/i2c-1"
```

If user is part of i2c group you should be able to run as user.

```
i2cdetect –y 1
nfc-list
nfc-poll
```