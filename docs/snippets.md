# SNIPPETS

## System

Disk usage nicely formatted `du -sh *` or `du -s * | sort -nr | head`

**/ is in read-only mode**
`mount -o remount,rw /` 
You'll still need to check the partition for errors. If you have physical access to server or KVM, boot it in single mode, unmount all the partitions, and run `fsck`.
If you dont have a physical access try `touch /forcefsck` this will force File System Check on the next reboot.

## NGINX

Remove the `.html` from the end of page URLs.

```
location / {
    if ($request_uri ~ ^/(.*)\.html) {
        return 302 /$1;
    }
    try_files $uri $uri.html $uri/ =404;
}
```

## Desktop

Move bluetooth default download directory, use absolute path.

`gsettings get org.blueman.transfer shared-path /home/$USER/dir`

## Windows

Grab your license key `wmic path SoftwareLicensingService get OA3xOriginalProductKey`.
