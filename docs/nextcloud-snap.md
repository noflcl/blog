# Install Nextcloud Snap

`sudo snap install nextcloud`

```
sudo nextcloud.manual-install user pass
sudo nextcloud.occ config:system:set trusted_domains 1 --value=fqdn
sudo nextcloud.occ config:system:get trusted_domains
sudo nextcloud.enable-https lets-encrypt
```
