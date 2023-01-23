# YubiKey

**Configuring YubiKey as PIV SmartCard for SSH**

``` 
sudo add-apt-repository ppa://yubico/stable
sudo apt update
sudo apt install yubikey-manager
```

Note: `yubikey-manager` good enough for cli. `yubikey-piv-manager` requires qt dependencies.

**Reset the YubiKey and set new mgm-key, pin, and puk**

`ykman piv reset`

**Setup new mgm-key, pin, and puk**

```
yubico-piv-tool -a set-mgm-key -n <key>
yubico-piv-tool -a change-pin -P123456 -N <pin>
yubico-piv-tool -a change-puk -P12345678 -N <puk>
```

**URLs for info**

[SSH /w PIV](https://developers.yubico.com/PIV/Guides/SSH_with_PIV_and_PKCS11.html)

[Generate Keys Using OpenSSL](https://developers.yubico.com/PIV/Guides/Generating_keys_using_OpenSSL.html)

[ykman Piv Delete](https://support.yubico.com/support/solutions/articles/15000012643-yubikey-manager-cli-ykman-user-manual#ykman_piv_delete-certificater7eqcn)

