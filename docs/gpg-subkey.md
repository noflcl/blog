# PGP
**With Sub-Keys**

### encrypt, sign, authenticate

First create a gpg.conf file with some sane defaults to enhance the security of your key generation.

`~/.gnupg/gpg.conf`

```
# Avoid information leaked
no-emit-version
no-comments
export-options export-minimal

# Displays the long format of the ID of the keys and their fingerprints
keyid-format 0xlong
with-fingerprint

# Displays the validity of the keys
list-options show-uid-validity
verify-options show-uid-validity

# Limits the algorithms used
personal-cipher-preferences AES256
personal-digest-preferences SHA512
default-preference-list SHA512 SHA384 SHA256 RIPEMD160 AES256 TWOFISH BLOWFISH ZLIB BZIP2 ZIP Uncompressed

cipher-algo AES256
digest-algo SHA512
cert-digest-algo SHA512
compress-algo ZLIB

disable-cipher-algo 3DES
weak-digest SHA1

s2k-cipher-algo AES256
s2k-digest-algo SHA512
s2k-mode 3
s2k-count 65011712
```
### Take Advantage Of Subkeys

OpenPGP allows you to create subkeys with specific uses: encrypt, sign, and authenticate. One of the main advantages of using subkeys is that in the event of loss or theft of the secret keys, you only need to revoke the subkey without needing to revoke the master key. 

### Create Master Key

```
gpg --expert --full-gen-key

Please select what kind of key you want:
   (1) RSA and RSA (default)
   (2) DSA and Elgamal
   (3) DSA (sign only)
   (4) RSA (sign only)
   (7) DSA (set your own capabilities)
   (8) RSA (set your own capabilities)
   (9) ECC and ECC
  (10) ECC (sign only)
  (11) ECC (set your own capabilities)
Your selection? 8
```
Then select the attributes only capabale of **Certify**.

```
Possible actions for a RSA key: Sign Certify Encrypt Authenticate
Current allowed actions: Sign Certify Encrypt

   (S) Toggle the sign capability
   (E) Toggle the encrypt capability
   (A) Toggle the authenticate capability
   (Q) Finished

Your selection? s

Possible actions for a RSA key: Sign Certify Encrypt Authenticate
Current allowed actions: Certify Encrypt

   (S) Toggle the sign capability
   (E) Toggle the encrypt capability
   (A) Toggle the authenticate capability
   (Q) Finished

Your selection? e

Possible actions for a RSA key: Sign Certify Encrypt Authenticate
Current allowed actions: Certify

   (S) Toggle the sign capability
   (E) Toggle the encrypt capability
   (A) Toggle the authenticate capability
   (Q) Finished

Your selection? q
```
Select your key size maximum being 4096. Now set your years until the key expires, usually set to 2 years, or in bad practice "key does not expire" is some cases.

Fill in the next prompts with your information and continue.

**Password protect your key with a strong unique password**.

### Create Subkeys

It is important to have dedicated subkeys for each task:

+ Encrypt (E)
+ Sign (S)
+ Authenticate (A)
 
` gpg --list-keys`

`gpg --expert --edit-keys 0x7FFDD3D3B027CE6B`

As you can tell from your bash prompt you are now in gpg edit mode.
Let's create the **encrypt subkey** first.

```
gpg> addkey
Please select what kind of key you want:
   (3) DSA (sign only)
   (4) RSA (sign only)
   (5) Elgamal (encrypt only)
   (6) RSA (encrypt only)
   (7) DSA (set your own capabilities)
   (8) RSA (set your own capabilities)
  (10) ECC (sign only)
  (11) ECC (set your own capabilities)
  (12) ECC (encrypt only)
  (13) Existing key
Your selection? 6
```
Enter your passphrase and set your key length and expiration.
Now let's create the **signing subkey**.

```
gpg> addkey
Please select what kind of key you want:
   (3) DSA (sign only)
   (4) RSA (sign only)
   (5) Elgamal (encrypt only)
   (6) RSA (encrypt only)
   (7) DSA (set your own capabilities)
   (8) RSA (set your own capabilities)
  (10) ECC (sign only)
  (11) ECC (set your own capabilities)
  (12) ECC (encrypt only)
  (13) Existing key
Your selection? 4
```
Enter your passphrase and set your key length and expiration.

Now let's create the **authentication subkey**.

```
gpg> addkey
Please select what kind of key you want:
   (3) DSA (sign only)
   (4) RSA (sign only)
   (5) Elgamal (encrypt only)
   (6) RSA (encrypt only)
   (7) DSA (set your own capabilities)
   (8) RSA (set your own capabilities)
  (10) ECC (sign only)
  (11) ECC (set your own capabilities)
  (12) ECC (encrypt only)
  (13) Existing key
Your selection? 8

Your selection? S

Possible actions for a RSA key: Sign Encrypt Authenticate 
Current allowed actions: Encrypt 

   (S) Toggle the sign capability
   (E) Toggle the encrypt capability
   (A) Toggle the authenticate capability
   (Q) Finished

Your selection? E

Possible actions for a RSA key: Sign Encrypt Authenticate 
Current allowed actions: 

   (S) Toggle the sign capability
   (E) Toggle the encrypt capability
   (A) Toggle the authenticate capability
   (Q) Finished

Your selection? A

Possible actions for a RSA key: Sign Encrypt Authenticate 
Current allowed actions: Authenticate 

   (S) Toggle the sign capability
   (E) Toggle the encrypt capability
   (A) Toggle the authenticate capability
   (Q) Finished

Your selection? Q
```

Once complete save your work.
 
 `gpg> save`
 
### Export The Master
 
 The master key which will allow you to certify will be stored in a cold storage (**offline**).
 
 First step is to create a revocation certificate in the event of a master key theft.
 
 `gpg --output  0x7FFDD3D3B027CE6B.rev --gen-revoke  0x7FFDD3D3B027CE6B`
 
 The revocation certificate **must** be preserved in a **safe place**.

 Save all the keys as well.
 
```
gpg --export --armor  0x7FFDD3D3B027CE6B >  0x7FFDD3D3B027CE6B.pub.asc
gpg --export-secret-keys --armor  0x7FFDD3D3B027CE6B >  0x7FFDD3D3B027CE6B.priv.asc
gpg --export-secret-subkeys --armor  0x7FFDD3D3B027CE6B >  0x7FFDD3D3B027CE6B.sub_priv.asc
```
 `0x7FFDD3D3B027CE6B.pub.asc` will contain all public keys.
 
 `0x7FFDD3D3B027CE6B.priv.asc` contains all the private keys of the master. 
 
 `0x7FFDD3D3B027CE6B.sub_priv.asc` contains only the private key of the subkeys.
 
 Since we will only be using the subkeys for daily use we can now delete all the private keys **AFTER** they are stored offline in a secure location.
 
 `gpg --delete-secret-key  0x7FFDD3D3B027CE6B`
 
 Then we import the private keys of the subkeys.
 
 `gpg ---import  0x7FFDD3D3B027CE6B.sub_priv.asc`
