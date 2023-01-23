# Shell Script To Nix
## Taking `.sh` and making it `.nix`

> Once I began to go down the Nix and NixOS rabbit hole there is no going back 😂!

Nix is slowly taking over and replacing every system around me. Until this last year I pretty much settled on Ubuntu Server for all my appliance and application server which includes pretty much every cloud instance as well. When I first got into Linux I was a serious distro hopper and big Arch fanboi 🫠 but as I progressed and managed more systems I started to settle on a familiar home of Ubuntu for all my mission critical systems. All of that us changing now.

Lets take a look at a `bash` script that deploys a generic server, with full disk encryption, remote unlocking, deployed with `Docker`, `KVM`, `ZFS`, `Samba`, `Wireguard`, and a few other things.

> "Let’s start at the very beginning, a very good place to start" - Julie Andrews

<p align="center">
<!-- 🤢 bit of a klugey directory traversal.. These never looked good to me -->
  <img src="../../../assets/images/julie-andrews.jpeg">
</p>
