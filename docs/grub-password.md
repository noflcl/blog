# GRUB Password

Backup files `etc/grub.d/00_header /etc/grub.d/10_linux /etc/grub.d/30_os-prober` before making changes.

**Protect All Ubuntu Entries**

In `/etc/grub.d/10_linux`, find the following line:

    `printf "menuentry '${title}' ${CLASS} {\n" "${os}" "${version}"`

Add `--users ''` tag:

    `printf "menuentry '${title}' ${CLASS} --users '' {\n" "${os}" "${version}"`

Save file, update grub:

    'sudo update-grub'

**Protect Other Entries**

Automatically password protect all entries in the `30_os-prober section`. Alter the `/etc/grub.d/30_os-prober` to add password protection to all entries:

`sudo sed 's/--class os /--class os --users /' -i /etc/grub.d/30_os-prober`

Update grub:

    'sudo update-grub'

To enable password protection only on a specific type of operating system add --users immediately following "--class os".

```
Windows:
    menuentry "${LONGNAME} (on ${DEVICE})" --class windows --class os { 

Linux/Ubuntu:
    menuentry "${LLABEL} (on ${DEVICE})" --class gnu-linux --class gnu --class os { 
```

**Protect Windows Recovery Partition**

Any Windows partition could be protected in the same manner by designating the partition. This technique will work only if the GRUB 2 menu identifies multiple Windows partitions and one of them is the recovery partition. If only one Windows partition is identified by GRUB due to Windows chainloading it's menus, only Windows in its entirety could be protected.

Determine the Windows Recovery partition (sda1, sda2, etc). Change sdXY to the correct values in the `/etc/grub.d/30_os-prober` file.

Change from:

```
    cat << EOF

    menuentry "${LONGNAME} (on ${DEVICE})" --class windows --class os {

    EOF
```

To (with correct value):

```
    if [ ${DEVICE} = "/dev/sdXY" ]; then

    cat << EOF

    menuentry "${LONGNAME} (on ${DEVICE})" --users "" {

    EOF

    else

    cat << EOF

    menuentry "${LONGNAME} (on ${DEVICE})" {

    EOF

    fi
```

Save file, update grub:

    `sudo update-grub`

**Password Encryption**

Note: "**It is worth repeating**: Users experimenting with GRUB 2 passwords should keep at least one non-protected menuentry and set the timeout to at least 1 second until testing is complete. This will allow booting a menuentry without a password to correct problematic settings."

**Generate Password**

`grub-mkpasswd-pbkdf2`

**Setup User / Password**

The format for an encrypted password entry in `/etc/grub.d/00_header`:

```
set superusers="foouser"
password_pbkdf2 foouser grub.pbkdf2.sha512.10000.*** ---> *** 
```