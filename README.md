# Load the keyboard mapping:
# (you can change to your country, like de-latin)

loadkeys br-abnt2


# Sync the clock:

timedatectl set-ntp true


# Shows an list of partitions:

fdisk -l


# Format partitions and mark only Linux as bootable:

cfdisk


# Format partition X to ext4 and Y to swap (and active her):

mkfs.ext4 /dev/sdaX
mkswap /dev/sdaY
swapon /dev/sdaY


# Mount partition X in /mnt:

mount /dev/sdaX /mnt


# Edit the mirrorlist and put the nearby server at the beggining:
## Go to the nearby server, use "CTRL + K" to cut
## and "CTRL + U" to paste at top. Save with "CTRL + O" and closes
## with "CTRL + X"

nano /etc/pacman.d/mirrorlist


# Use pacstrap script to install essentials packages in /mnt:

pacstrap -i /mnt base base-devel


# Generate the fstab:

genfstab -U /mnt >> /mnt/etc/fstab


# Verify if the fstab is right (check if all partitions is here):

cat /mnt/etc/fstab


# Change the root shell to the new installed system:

arch-chroot /mnt


# Download and run the script:

pacman -Syu ; pacman -S git
git clone https://github.com/renanmarcs/install-arch.git
cd install-arch
chmod a+x install.sh
./install.sh

