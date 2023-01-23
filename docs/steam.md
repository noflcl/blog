# Steam Server

If you need to create a new server and mount a storage volume with your games folder, just create a new directory and symlink the old one.

If you have already moved the folder adjust permissions:

`sudo chmod a+rwx -R /foo/games`

**UFW Firewall**

```
sudo ufw allow proto tcp from IP.ON.LAN to any port 27036,27037
sudo ufw allow proto udp from IP.ON.LAN to any port 27031,27036
```

**Move Steam Data**

Move all your Steam data to your bulk storage device rather than locally. Remeber to launch steam first to select the Download location because it needs to be an empty folder.

Locate your Steam files `cd / && sudo find -name steam`. The `/home/$USER/Steam` folder is only for log files Downloaded data, client updates, etc.

```
mkdir /mnt/steam/SteamFiles
chown myuser:mygroup /mnt//steam/SteamFiles
cd ~
ln -s /mnt/steam/SteamFiles .steam
```