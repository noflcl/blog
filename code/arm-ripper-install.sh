echo -e "This script will install ARM - Automatic Ripping Machine \n"
echo -e "Check out the GitHub for more information. \n"
echo -e "https://github.com/automatic-ripping-machine/automatic-ripping-machine.git \n"

while true; do
    read -p "Would you like to install now (y/n)?" choice
    case "$choice" in
	y|Y ) echo -e "Alright, here we go! \n";;
	n|N ) echo -e "Alright, feel free to run this script when ready. \n"
        read -n1 -r -p "Press any key to exit..."
        quit; break ;;
	*  ) echo -e "invalid \n";;
    esac
done

sudo groupadd arm
sudo useradd -m arm -g arm -G cdrom
sudo passwd arm
sudo apt-get install git -y
sudo add-apt-repository ppa:heyarje/makemkv-beta
sudo add-apt-repository ppa:stebbins/handbrake-releases
sudo add-apt-repository ppa:mc3man/focal6


sudo apt update -y && \
sudo apt install makemkv-bin makemkv-oss -y && \
sudo apt install handbrake-cli libavcodec-extra -y && \
sudo apt install abcde flac imagemagick glyrc cdparanoia -y && \
sudo apt install at -y && \
sudo apt install python3 python3-pip -y && \
sudo apt-get install libcurl4-openssl-dev libssl-dev -y && \
sudo apt-get install libdvd-pkg -y && \
sudo dpkg-reconfigure libdvd-pkg && \
sudo apt install default-jre-headless -y

cd /opt
sudo mkdir arm
sudo chown arm:arm arm
sudo chmod 775 arm
sudo git clone https://github.com/automatic-ripping-machine/automatic-ripping-machine.git arm
sudo chown -R arm:arm arm
cd arm
sudo pip3 install -r requirements.txt
sudo cp /opt/arm/setup/51-automedia.rules /etc/udev/rules.d/
sudo ln -s /opt/arm/setup/.abcde.conf /home/arm/
sudo cp docs/arm.yaml.sample arm.yaml
sudo mkdir /etc/arm/
sudo ln -s /opt/arm/arm.yaml /etc/arm/

sudo mkdir -p /mnt/dev/sr0

sudo bash -c 'cat >> /etc/fstab' <<EOF
/dev/sr0  /mnt/dev/sr0  udf,iso9660  users,noauto,exec,utf8  0  0
EOF


