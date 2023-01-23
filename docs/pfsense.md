# pfSense
**pfSense Can't Upgrade to 2.4**

Original post on Netgate forums [here](https://forum.netgate.com/topic/121783/solved-update-2-3-4-to-2-4-failed-unable-to-check-for-updates).

Cleaned up link-mess in `/var/cache/pkg`.

```
$ ls -lha /var/cache/pkg 
lrwxr-xr-x  1 root  wheel    24B Oct 21 02:27 /var/cache/pkg -> ../../root/var/cache/pkg
```

Delete an "`.empty`" file in `/usr/local/share/pfSense/keys/pkg/revoked/` (check below for other key-issues).

Install packages via `pkg-static` and `upgrade`.

```
pkg-static update -f
pkg-static install -f pkg
pkg-static install -y pfSense pfSense-base pfSense-repo pfSense-kernel-pfSense pfSense-rc pfSense-repo pfSense-upgrade

pkg-static unlock pfSense-kernel-pfSense
pkg-static upgrade -f
pkg-static lock pfSense-kernel-pfSense

pfSense-upgrade -d
```

nstalled and Removed acme package via GUI to get rid of crash reports.