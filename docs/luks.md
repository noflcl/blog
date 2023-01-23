# LUKS

**List keys**

`sudo cryptsetup luksDump /dev/sdx1 | grep "Key Slot"`

**Add key**

`sudo cryptsetup -v luksAddKey /dev/sdx`

`sudo cryptsetup -v luksAddKey /dev/sdx1 /etc/luks-keys/disk_secret_key`

You can also specify the key slot you want to fill.

`sudo cryptsetup -v luksAddKey --key-slot 7 /dev/sdx`

Creating keys for encrypted drives is simple, remember this key is highly sensitive.

`sudo dd bs=512 count=8 if=/dev/urandom of=/etc/luks-keys/disk_secret_key`

```
sudo cryptsetup -v luksOpen /dev/sdx1 sdx1_crypt --key-file=/etc/luks-keys/disk_secret_key`

sudo cryptsetup -v luksClose /dev/sdx1
```

**Change passphrase**

`sudo cryptsetup -v luksChangeKey /dev/sdx`

`sudo cryptsetup -v luksChangeKey --key-slot 5 /dev/sdx`

**Remove passphrase**

`sudo cryptsetup -v luksRemoveKey /dev/sdx1`

`sudo cryptsetup -v luksKillSlot /dev/sdx7`

**Format disk with luks**

`cryptsetup --cipher aes-xts-plain64 --key-size 512 --hash sha512 --iter-time 5000 luksFormat /dev/sdax`