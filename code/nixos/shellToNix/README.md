# Shell Script To Nix
## Taking `.sh` and making it `.nix`

> Once I began to go down the Nix and NixOS rabbit hole there is no going back 😂!

Nix is slowly taking over and replacing every system around me. Until this last year I pretty much settled on Ubuntu Server for all my appliance and application servers which includes pretty much every cloud instance as well. When I first got into Linux I was a serious distro hopper and big Arch fanboi 🫠 but as I progressed and managed more systems I started to settle on a familiar home of Ubuntu for all my mission critical systems. All of that us changing now.

Lets take a look at a `bash` script that deploys a generic server, with full disk encryption, remote unlocking, deployed with `Docker`, `KVM`, `ZFS`, `Samba`, `Wireguard`, and a few other things.

> "Let’s start at the very beginning, a very good place to start" - Julie Andrews

<p align="center">
<!-- 🤢 bit of a klugey directory traversal.. These never looked good to me -->
  <img src="../../../assets/images/julie-andrews.jpeg">
</p>

## What does the bash script do?

### Usage of script / help menus
The first few lines of my script usually contain a variable that fetches the name of the script that is being executed. 

``` bash
declare _PROGNAME

_PROGNAME=$(basename -- "$0")
```
This variable is handy when putting together a help menu or a notice to a user about how to use this script.

```bash
usage() {
	cat <<EOF

Usage: $_PROGNAME <options>
Options:
    -i, --install		Install software
EOF
}

if [[ "$1" == "" ]]; then
	usage
	exit 0
fi
```

The `usage()` function will be printed to the console if someone runs the script with no arguments giving them a nice "how to use" and the `$_PROGNAME` variable will be printed out with the scripts real name "`install.sh`".

## Decrypt Disks
---
### `root`
When installing my operating system I *opt in* to enable full disk encryption partnered with `Dropbear` for remote unlocking. I have Dropbear listening on a random port, and store that unique data in my password manager along side the server credentials. I also use a unique keypair seperate from my users SSH keys just for unlocking a disk.

<details>
  <summary>_DROPBEAR( )</summary>

```bash
_DROPBEAR() {
	echo -e "Installing Dropbear..."
	sudo apt -y install dropbear
	sudo systemctl disable dropbear
	sudo bash -c 'cat > /etc/dropbear-initramfs/authorized_keys' <<EOF
ssh-rsa Public Key Goes Here
EOF

	echo -e "Do you want to set a static IP for Dropbear?"
	while true; do
		read -p "Select (y/n)?" choice
		case "$choice" in
		y|Y ) sudo bash -c 'cat >> /etc/initramfs-tools/initramfs.conf' <<EOF
IP=YOUR-IP-HERE::YOUR-DEFAULT-ROUTE-HERE:255.255.255.0::YOUR-INTERFACE-HERE:off
EOF
		break ;;
		n|N ) echo -e "Your DHCP server will give Dropbear a unique address \n" ; break ;;
		  * ) echo -e "invalid \n" ;;
		esac
	done

	wget https://gist.githubusercontent.com/gusennan/712d6e81f5cf9489bd9f/raw/fda73649d904ee0437fe3842227ad8ac8ca487d1/crypt_unlock.sh
	sudo mv crypt_unlock.sh /etc/initramfs-tools/hooks/
	sudo chmod +x /etc/initramfs-tools/hooks/crypt_unlock.sh

	sudo bash -c 'cat >> /etc/dropbear-initramfs/config' <<EOF
DROPBEAR_OPTIONS="-p YOUR-PORT-HERE"
EOF

	echo -e "\n Updating initramfs...\n"
	
	sudo update-initramfs -u
}
```
</details>

<br>

### Bulk Storage
This is my old way of handling luks encrypted storage. After weighing my threat level I settled on the convenience of keyfiles to unlock my encypted storage drives before ZFS mounts them. Since my whole root disk is encrypted already, the keyfile is protected at rest, and it is placed in my root directory with constrained permissions so non root users can't get to it.

My current solution is now using native ZFS encryption which solves every problem for bulk data storage.. But here was my old way of managing encrypted storage pools at boot.

<details>
  <summary>_DECRYPT( )</summary>

```bash
_DECRYPT() {
	# Setup disk decryption
	if [ -d /root/.key ]; then
		sudo dd if=/dev/urandom of=/root/.key/nasmaster bs=512 count=8
	else
		sudo mkdir /root/.key
		sudo dd if=/dev/urandom of=/root/.key/nasmaster bs=512 count=8
	fi
	echo -e "\nYou must manually enter your hdd encryption keys"
	read -n1 -r -p "Press enter to continue..."
	echo -e "Enter your passphrase for nas_4tb_00"
	sudo cryptsetup -v luksAddKey /dev/disk/by-id/$_DISK1 /root/.key/nasmaster
	echo -e "\nEnter your passphrase for nas_4tb_01"
	sudo cryptsetup -v luksAddKey /dev/disk/by-id/$_DISK2 /root/.key/nasmaster
	# Add to crypttab
	sudo bash -c 'cat >> /etc/crypttab' <<EOF
nas_4tb_00 UUID=$_UUID1 /root/.key/nasmaster luks
nas_4tb_01 UUID=$_UUID2 /root/.key/nasmaster luks
EOF
	# keyfile permissions
	sudo chmod 0400 /root/.key/nasmaster
	# Mount encrypted drives
	sudo cryptsetup luksOpen /dev/disk/by-id/$_DISK1 nas_4tb_00 --key-file=/root/.key/nasmaster
	sudo cryptsetup luksOpen /dev/disk/by-id/$_DISK2 nas_4tb_01 --key-file=/root/.key/nasmaster
}
```
</details>

<br>

## Software
---
I use to be all about KVM and wrapping software up in their own isolated environment with a very limited scope of access to the underlying storage and system. Since then, Docker has come to be my defacto standard on softare deployment with very few VM's these days.

<details>
  <summary>_DOCKER( )</summary>

```bash
_DOCKER() {
	echo -e "Installing Docker Community Edition..."
	sudo apt -y install apt-transport-https ca-certificates curl software-properties-common
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
	sudo apt update
	sudo apt -y install docker-ce docker-compose
	sudo usermod -aG docker $USER
}
```
</details>

<br>

IOMMU groups can be used to pass physical hardware directly to your virtual machines.

<details>
  <summary>_IOMMU( )</summary>

```bash
_IOMMU() {
	# Always run last, reboot required
	echo -e "\nEnabling iommu groups and isolating your GPU... \n"
	# "amd_iommu=on iommu=pt kvm_amd.npt=1 kvm_amd.avic=1"
	#sudo perl -i -pe 's/(GRUB_CMDLINE_LINUX_DEFAULT=.*)"/\1 amd_iommu=on iommu=pt"/' /etc/default/grub
    sudo perl -i -pe 's/(GRUB_CMDLINE_LINUX_DEFAULT=.*)"/$1amd_iommu=on iommu=pt vfio-pci.ids=1002:67df,1002:aaf0"/' /etc/default/grub
    
		echo -e "Does the format of your grub file look correct? \n"
		grep GRUB_CMDLINE_LINUX_DEFAULT /etc/default/grub
	while true; do
		read -p "Select (y/n)?" choice
		case "$choice" in
		y|Y ) echo -e "Your system will reboot now..." ; break ;;
		n|N ) echo -e "Please manually edit your /etc/default/grub file before rebooting your system. \n"; exit 1 ;;
		  * ) echo -e "invalid \n" ;;
		esac
	done

	echo -e "\nYou can now reboot your server. \n"
}
```
</details>

<br>

KVM for virtual machines.

<details>
  <summary>_KVM( )</summary>

```bash
_KVM() {
	sudo apt -y install qemu-kvm qemu-utils ovmf libvirt-daemon-system libvirt-clients bridge-utils virt-manager
	sudo usermod -aG kvm "${USER}"
	sudo usermod -aG libvirt "${USER}"

	echo -e "\nDo you want to install a minimal desktop for x2go sessions? \n"
		while true; do
		read -p "Select (y/n)?" choice
		case "$choice" in
		y|Y ) sudo apt -y install --no-install-recommends xorg 
		sudo apt -y install openbox lxpolkit 
		sudo apt -y install --no-install-recommends x2goserver x2goserver-xsession
		bash -c cat > '$HOME/.xinitrc' <<EOF
#!/bin/bash
exec openbox-session
EOF
		if [ ! -d ~/.config ]; then
		mkdir ~/.config
		fi

		cp -R /etc/xdg/openbox ~/.config/
		bash -c cat > '$HOME/.config/autostart.sh' <<EOF
lxpolkit &
EOF
		chmod +x ~/.config/autostart.sh	; break ;;
		n|N ) echo -e "No desktop session has been installed. \n"; break ;;
		  * ) echo -e "invalid \n" ;;
		esac
	done
		# If using VS code on the remote host uncomment this:
		#sudo bash -c cat >> '/etc/x2go/x2goagent.options' <<EOF
#X2GO_NXAGENT_DEFAULT_OPTIONS+=" -extension BIG-REQUESTS"
#EOF
}
```
</details>

<br>

Samba setup for a simple media share that is `r/o`. This is a choice since users on my network only need to see the media, I don't need them deleting or modifying things. That's what the command line is for 🙃.

<details>
  <summary>_SAMBA( )</summary>

```bash
_SAMBA() {
	read -p "IP address range: " -e -i 10.0.0.0/24 _IPADDR
	sudo apt -y install samba
	sudo ufw allow from "$_IPADDR" to any port 445
	sudo ufw reload

	sudo groupadd multimedia
	echo -e "Let's setup Samba now. \n"
	read -n1 -r -p "Press enter to continue..."
	echo -e "\nSetup nologin user for smb share"
	read -p "User: " -e -i mediauser _SMBUSER
	sudo useradd -s /sbin/nologin "$_SMBUSER"
	sudo usermod -aG multimedia "$_SMBUSER"
	sudo usermod -aG multimedia "$(whoami)"
	echo -e "\nSetup Samba credentials for $_SMBUSER \n"
	sudo smbpasswd -a "$_SMBUSER"

	if [ -d $_MEDIA_DIR ]; then
        sudo chown -R shoci:multimedia $_MEDIA_DIR
	else
        echo -e "Video directory not present."
        echo -e "Check that ZFS is mounted correctly."
	fi

	sudo bash -c cat > '/etc/samba/smb.conf' <<EOF
[global]
   workgroup = WORKGROUP
   server string = Samba Server
   server role = standalone server
   panic action = /usr/share/samba/panic-action %d

   log level = 1
   log file = /var/log/samba/log.%m
   max log size = 1000
   logging = file
   
   interfaces = lo eno1
   bind interfaces only = yes
   hosts allow = 127. 10.0.0.
   hosts deny = 0.0.0.0/0
  
   disable netbios = yes
   smb ports = 445 
   min protocol = SMB2
   security = user
   obey pam restrictions = yes
   unix password sync = yes
   passwd program = /usr/bin/passwd %u
   passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .
   pam password change = yes
   map to guest = bad user
   usershare allow guests = no

   load printers = no

   socket options = TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=65536 SO_SNDBUF=65536
   read raw = yes
   write raw = yes
   max xmit = 65535
   dead time = 15
   getwd cache = yes
   strict allocate = no
   server signing = no
   strict locking = no
   oplocks = yes
   min receivefile size = 16384
   use sendfile = no
   server multi channel support = yes
   aio read size = 16384
   aio write size = 16384

[video-share]
   comment = Read Only Video Share
   path = /mnt/media/video
   valid users = @multimedia
   guest ok = no
   writable = yes
   browsable = yes
   read only = yes
EOF

	sudo systemctl restart smbd
	systemctl is-active --quiet smbd && echo -e "\nSamba service is running."
}
```
</details>

<br>

Wireguard for my VPN.

<details>
  <summary>_WIREGUARD( )</summary>

```bash
_WIREGUARD() {
	# Enable packet forwarding
	sudo bash -c 'cat > /etc/sysctl.d/99-wireguard.conf' <<EOF
net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1
EOF

	sudo sysctl -p /etc/sysctl.d/99-wireguard.conf
	sudo apt -y install wireguard

  echo -e "\nWireguard is now installed, you may import your config file.\n"
}
```
</details>

<br>

Installing ZFS for storage pool.

<details>
  <summary>_ZFS( )</summary>

```bash
_ZFS() {
	# Install ZFS and import all pools
	sudo apt -y install zfsutils-linux
	sudo zpool import -a -f

	if zpool list >/dev/null; then
		echo -e "\n   Your zpool has imported correctly\n"
	else
		echo -e "\n   Your zpool did not import correctly.\n"
		echo -e "   Check your ZFS logs."
	fi
}
```
</details>

<br>

# Nix
## Let's get a bit of Nix up in here

If we look over the script it really does three things:
- Sets up the system for remote decryption & decrypting of bulk storage
- Installs the required software for the server
- Configures the software

Since Nix language is nothing like a bash script, what we previously used to deploy systems really can only be used as a roadmap. One thing I want to accomplish is being able to reuse the same nix files across multiple systems but not every device will have all of these services. An easy solution would be to wrap each service in their own `.nix` file and just import the files needed into the config per system.

```nix
import = 
  [
    wireguard.nix
    samba.nix
    ...
  ];
```

## Decrypt Disks
---
### `root`

Dropbear has nix support and great documentation in the [Nix wiki](https://nixos.wiki/wiki/Remote_LUKS_Unlocking). One of the interesting things for Nix is they recommend doing this over Tor 😎 doesn't get much cooler than that.
