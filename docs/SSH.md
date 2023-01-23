# SSH

**Generate**

`ssh-keygen -a 100 -t ed25519`

`ssh-keygen -a 100 -t rsa -b 4096`

**Permissions**

```
chmod 700 ~/.ssh
chmod 644 ~/.ssh/authorized_keys
chmod 644 ~/.ssh/known_hosts
chmod 644 ~/.ssh/config
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
```

**Banner**

Giving a warning before a user attempts to login to a server that they may not own can be a simple yet effective deterrent from basic mischief.

ALERT! You are entering into a secured area! Your IP, Login Time, Username have been noted and has been sent to the server administrator!
This service is restricted to authorized users only.

In order to create a banner like this, place a file **issue.net**  in your /etc/ directory (this can actually be placed anywhere just point to it in sshd config).
Inside your sshd config file, find the "Banner" line, uncomment it and point to you issue.net file.

`sudo systemctl restart ssh`

**Custom message after login**

To give a custom message after a user has logged into a server create or edit the /etc/motd file.
You can create elaborate login messages with a directory /etc/update-motd.d
and pass files that are parsed in lexical order.

```
10-login-header
30-login-sysinfo
35-tips
```