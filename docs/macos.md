# MacOS Notes

## Installing Issues

**Not Enough Space On Device**

> MediaKit reports not enough space on device for requesting operation.

If your device throws this error message when using Disk Utility to format the device exit the program and launch your terminal.

Find your device:

`diskutil list`

```
diskutil umountDisk force /dev/foo
dd if=/dev/zero of=/dev/foo bs=1024 count=1024
diskutil partitionDisk /dev/foo GPT JHFS+ "device-name" 0g
```

**Damaged Installer Application**

>This copy of the install macOS mojave.app application is damaged and can't be used to install macOS

Close the installer, open your terminal, and check your date and time with the `date` command.

The format for macOS date and time is `[mm][dd]HH]MM[yy]`.

```
date 061322072019
```

### Error Verifying Firmware

APFS is Apples new filesystem and is the default filesystems for SSD drives, but APFS requires a firmware upgrade for your system to see the devices. If you have replaced your logic board or have a "new" old mac, the install MUST be started with a spinning rust HDD for the system to be able to patch its firmware. Once the firmware patches you can abort the install, put your new SSD into the system and start the install over again.

After a fresh install of macOS the first restart triggers the installer to prepare the latest version firmware which is suitable for your mac model onto the EFI system partition of your main disk with the bless command. Then it restarts again and automatically triggers the firmware upgrade process.

**Your drive MUST be installed using the internal SATA cable for this to work, USB connected hard drives will fail the firmware upgrade process.**
## 