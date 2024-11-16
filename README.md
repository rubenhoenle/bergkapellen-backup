![Bergkapelle sync](https://healthchecks.io/b/2/d8b1736e-8bd3-4b75-8a14-16984e3d5637.svg)
![Bergkapelle restic](https://healthchecks.io/b/2/64ac11c2-0699-4626-8e1a-94c9ce560a9c.svg)

# Bergkapelle Nextcloud Backup configuration

This is a bare minimum config to build a NixOS Raspberry Pi SD card image which is used inside a Raspberry Pi to backup a SaaS Nextcloud instance.

Hardware setup: 

* Raspberry Pi 4 with 2GB RAM
* external Hard drive

## Everything you should know

* The hard drive is formatted in `ext4` and may not be readable using a Windows machine. Just in case I leave this world and you need to access these backups, use a Linux machine to read it.
* The hard drive contains two directories:
    * `synced`: This directory always contains the latest files from the Nextcloud instance. It should be synced every hour.
    * `restic`: This directory contains a [restic](https://restic.net/) repository. Restic is a backup tool which supports incremental backups and deduplication. Using the restic software you should be able to jump back to the file structure of the Nextcloud from the latest
        * 48 hours
        * 7 days
        * 4 weeks
        * 12 months
        * 10 years

## Rebuilding

```bash
nixos-rebuild switch --target-host root@bergkapellen-backup --flake ".#raspberry-pi_4"
```

## Helpful commands

```bash
# starting the sync job manually (should start the restic backup job automatically afterwards)
systemctl start nc-backup

# view status of the sync job
systemctl status nc-backup

# starting the restic job manually
systemctl start restic-backups-nextcloud

# view status of the restic job
systemctl status restic-backups-nextcloud
```

## Building the SD card image for a new setup

> [!NOTE]
> This might take a while and eat up some disk space on your machine.

### Prerequisites
To be able to build the SD card image on your local x86 machine, you will have to add the following lines to your nix system config.

```nix
boot.binfmt.emulatedSystems = ["aarch64-linux"];
nix.settings.extra-platforms = config.boot.binfmt.emulatedSystems;
```

### Building the image and flashing the SD card

```bash
nix build .#nixosConfigurations.raspberry-pi_4.config.system.build.sdImage
```

## Flash the ISO to the SD card

```bash
# run this before inserting the sd card
lsblk

# NAME                                          MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINTS
# sda                                             8:0    1     0B  0 disk
# sdb                                             8:16   1     0B  0 disk

# now insert the SD card, then run it again
lsblk

# NAME                                          MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINTS
# sda                                             8:0    1     0B  0 disk
# sdb                                             8:16   1  29,8G  0 disk
# ├─sdb1                                          8:17   1   256M  0 part  /run/media/ruben/bootfs
# └─sdb2                                          8:18   1  29,6G  0 part  /run/media/ruben/rootfs

# NOW WE KNOW: OUR SD CARD IS /dev/sdb

# unmount the sd card
sudo umount /dev/sdb1
sudo umount /dev/sdb2

# get the path of your iso in the nix store
# BE CAREFUL: The iso image is hidden in a subdirectory inside the nix store
ls -lisa result

# write the ISO to the SD card
sudo dd if=/nix/store/xz8hw00mpcgl1y7fd4g58x1ilnpwbjkz-nixos-sd-image-24.11.20240608.cd18e2a-aarch64-linux.img/sd-image/nixos-sd-image-24.11.20240608.cd18e2a-aarch64-linux.img of=/dev/sdb bs=1M status=progress
```

