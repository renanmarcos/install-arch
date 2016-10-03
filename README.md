# Install Arch Script

[![Project Status: WIP](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip)

This is an simple script written in ShellScript and made for installing Arch Linux more easily and without typing so much. Initially I created this for personal use and for studying objectives, but you can use this for any reason. And if you want to help and contribute, is free and open source to do what you want.

This is destined for intermediate/expert users, because doens't install all things from zero. This will only install and configures packages after mounting system in '/mnt' partition and changing to arch-chroot.

If you are newbie or don't know so much about Arch Linux, it's recommended to read the [Arch Wiki](https://wiki.archlinux.org/).

ATTENTION: I've not tested this script yet in an installation. If you find any bugs, please report into 'Issues' tab.

## An quick guide to installing Arch Linux and executing the script

### Load the keyboard mapping:
You can change according your country, like *de-latin1*

```sh
$ loadkeys br-abnt2
```

### Sync the clock:
```sh
$ timedatectl set-ntp true
```

### Shows an list of partitions:

```sh
$ fdisk -l
```

### Format partitions and mark only Linux as bootable:

```sh
$ cfdisk
```

### Format partition X to ext4 and Y to swap (and active her):

```sh
$ mkfs.ext4 /dev/sdaX
$ mkswap /dev/sdaY
$ swapon /dev/sdaY
```

### Mount partition X in /mnt:
```sh
$ mount /dev/sdaX /mnt
```

### Edit the mirrorlist and put the nearby server at the beggining:
Go to the nearby server, use "CTRL + K" to cut and "CTRL + U" to paste at top. Save with "CTRL + O" and closes with "CTRL + X"

```sh
$ nano /etc/pacman.d/mirrorlist
```

### Use pacstrap script to install essentials packages in /mnt:
```sh
$ pacstrap -i /mnt base base-devel
```

### Generate the fstab:
```sh
$ genfstab -U /mnt >> /mnt/etc/fstab
```
### Verify if the fstab is right (check if all partitions is here):
```sh
$ cat /mnt/etc/fstab
```

### Change the root shell to the new installed system:
 ```sh
$ arch-chroot /mnt
```

### Download and run the script:
 ```sh
$ pacman -Syu ; pacman -S git
$ git clone https://github.com/renanmarcs/install-arch.git
$ cd install-arch ; chmod a+x install.sh
$ ./install.sh
```
