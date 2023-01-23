# KVM

## GPU Passthrough

When using virtualization passthrough, and on VM shutdowns, Linux can have issues freeing the GPU back to the system. Execute the script before starting the VM again. You will need to press the power button on your server to wake the system back up. 

**Note**: Buy a motherboard with IPMI next time `* face palm * `. Thanks to [Spaceinvader One](https://www.youtube.com/channel/UCZDfnUn74N0WeAPvMqTOrtA) for this script. 

```
#!/bin/bash

#replace xx\:xx.x with the number of your gpu and sound counterpart

echo "disconnecting amd graphics"
# echo "1" | tee -a /sys/bus/pci/devices/0000\:xx\:xx.x/remove
echo "1" | tee -a /sys/bus/pci/devices/0000\:09\:00.0/remove
echo "disconnecting amd sound counterpart"
# echo "1" | tee -a /sys/bus/pci/devices/0000\:xx\:xx.x/remove
echo "1" | tee -a /sys/bus/pci/devices/0000\:09\:00.1/remove
echo "entered suspended state press power button to continue"
echo -n mem > /sys/power/state
echo "reconnecting amd gpu and sound counterpart"
echo "1" | tee -a /sys/bus/pci/rescan
echo "AMD graphics card sucessfully reset
```

## Shared Storage

If you want expose a directory to your VM first create the folder on the host `mkdir /folder && chmod 777 /folder`.

Verify VM is shutown.

   - Switch the view to detail hardware view: View > Details
   - Go to Attach hardware > Filesystem
   - Fill in the name of the source path `/folder` and virtual target path `/sharehost`
   - Switch mode to `Mapped` if you need to have write access from the guest
   - Confirm and start the VM again

On the guest OS create a directory to mount `mkdir /share` then mount it `mount -t 9p -o trans=virtio /sharehost /share`.
If this is correct add an fstab entry to mount on boot.

`/sharehost /share 9p trans=virtio,version=9p2000.L,rw    0   0`

On the host OS SELinux won’t allow you to share this folder until it’s labeled `svirt_image_t`.

```
semanage fcontext -a -t svirt_image_t "/share(/.*)?"
restorecon -vR /share
```