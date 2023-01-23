# Encrypted Server
**UEFI boot and ZFS**

## EFI Partion

Create gpt partion table.

- create 256MB fat32 partion name: “EFI System Partition” label: “ESP”
- right-click, "manage flags" and check "esp"
- quit gparted

Run Ubuntu installer.

## Format Disc

- create 512MB ext2 partion set as /boot
- create "physical volume for encryption"

Quit the installer.

## Setup LVM Volumes

```
sudo -s
vgcreate fooname /dev/disk/by-id/dm-name_sda3_crypt
lvcreate -L 50G -n root fooname
lvcreate -l 100%FREE -n home fooname
```

Run Ubuntu installer.

## Install OS

"Something else" at the "Installation type".

- select /dev/sda1 EFI/ESP partion, set to: “EFI System Partition”
- select /dev/sda2 boot partion, set use as: “ext2 file system” mount point: “/boot”
- select /dev/mapperfooname-root, set use as: "ext4 journaling" mount point: "/" “Format the partition”
- select dev/mapper/fooname-home, set use as: "ext4 journaling" mount point: "/home" “Format the partition”
- select /dev/sda as “Device for boot loader installation”

Proceed with install, **do not reboot**.

"**Continue Testing**"

## Setup Encrypted ZFS Partition

`cgdisk /dev/sda`

Create partition in empty space with `BF01` as the hex code for ZFS. 

`cryptsetup luksFormat /dev/sda4`

Create key file for decryption of ZFS partition

```
mkdir /etc/crypt.d 
dd bs=515 count=4 if=/dev/urandom of=/etc/crypt.d/sda4.key
```

Add Key to luks

`cryptsetup luksAddKey /dev/sda4 /etc/crypt.d/sda4.key`

## Static Encryption Info For Boot And ZFS

```
sudo -s
blkid /dev/sda3
echo 'sda3_crypt UUID=(the uuid without quotes) none luks,discard' > /etc/crypttab
blkid /dev/sda4 
echo 'sda4_crypt UUID=(the uuid without quotes) /etc/crypt.d/sda4.key' >> /etc/crypttab
```

## Chroot 

Mount and chroot into new installation.

```
sudo mount /dev/mapper/system-root /target/root
sudo mount --bind /dev /target/dev
sudo mount --bind /run /target/run
sudo chroot /target
mount /dev/sda2 /boot
mount /dev/sda1 /boot/efi
mount --types=proc proc /proc
mount --types=sysfs sys /sys
```

**Install Bootloader**
 
```
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader=ubuntu --boot-directory=/boot/efi/EFI/ubuntu --recheck /dev/sda
grub-mkconfig --output=/boot/efi/EFI/ubuntu/grub/grub.cfg
update-initramfs -ck all
exit
```

You can safely reboot and install ZFS utils `sudo apt install zfsutils-linux`.

## Reinstall OS

Boot from USB.

```
sudo -s
cryptsetup luksOpen /dev/sda3 sda3_crypt
```

Repeat steps above from **Install OS** until reboot phase.

## System Doesn't Boot?

**What if/when the system doesn't boot?**

Boot from USB.

```
sudo mkdir /mnt/root
sudo cryptsetup luksOpen /dev/sda3 sda3_crypt
sudo mount /dev/mapper/system-root /mnt/root
sudo mount --bind /dev /mnt/root/dev
sudo mount --bind /run /mnt/root/run
sudo chroot /mnt/root
umount /boot
mkdir /boot
mount /dev/sda2 /boot
mount /dev/sda1 /boot/efi
mount --types=proc proc /proc
mount --types=sysfs sys /sys

(Insert your magic foo)

exit
reboot
```
