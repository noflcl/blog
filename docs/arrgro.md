# Arrg r/o

First time I ran into `dd: failed to open ‘/dev/sdX’: Read-only file system` was shortly after playing with my first Raspberry Pi and it had me completeley frustrated. Gparted, fdisk, and windows could not switch the `r/o` bit off. Through my searching for answers as to why this happens I came across a lot of speculation from failing SD, SD reader firmware -> SD, obscure permissions issues, and what I have found to work is as follows.

Make sure system is not auto mounting USB, I choose to stop my display manager.

`lsblk`

sdd                               8:48   1  14.6G  0 disk  

├─sdd1                            8:49   1   100M  0 part  

└─sdd2                            8:50   1  14.5G  0 part  

sr0

Make sure you select the correct drive

`sudo dd bs=32M count=50 if=/dev/zero of=/dev/sdd`

Now you can use fdisk to create new partion table and mkfs.

If dd still complains and wont write zeros to the drive than there is another option.

`sudo echo "0" > /sys/block/sdd/ro`

Repeate the above `dd` command.