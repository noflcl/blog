# Wireguard 

**Generate Keys**

```
(umask 077 && printf "[Interface]\nPrivateKey = " | sudo tee /etc/wireguard/wg0.conf > /dev/null)
wg genkey | sudo tee -a /etc/wireguard/wg0.conf | wg pubkey | sudo tee /etc/wireguard/publickey
```

**Config**

`/etc/wireguard/wg0.conf`

```
[Interface]
PrivateKey = 
ListenPort = 
SaveConfig = false
Address = IP/24
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer] #foo_peer
PublicKey = 
AllowedIPs = IP/32
```

**Enable IP Forwarding**

`/etc/sysctl.d/wireguard.conf`

```
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
```

`sudo sysctl -p /etc/sysctl.d/wireguard.conf`

**Set Directory Permissions**

```
sudo chown -R root:root /etc/wireguard
sudo chmod -R og-rwx /etc/wireguard/*
sudo systemctl enable wg-quick@wg0
```