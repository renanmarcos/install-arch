#!/bin/bash 

# Function for pause command
function pause(){
	read -p "Press [Enter] to proceed..."
}

# Shows an list of available regions
ls /usr/share/zoneinfo
echo " "
echo "Select your region and type above:"
read region
echo " "
echo " "

# Shows an list of available cities
ls /usr/share/zoneinfo/$region/
echo " "
echo "Type your city above:"
read city

# Symlink selected region and city to localtime and set time to UTC
ln -s /usr/share/zoneinfo/$region/$city /etc/localtime
hwclock --systohc --utc


# Configuring language and keymap
printf "You will be redirected to edit file '/etc/locale.gen'
please, uncomment the needed localizations
example: if you need 'en_US.UTF-8'... Go to line
and removes the '#' before this

Use 'CTRL + O' to save and 'CTRL + X' to exit


"
pause
nano /etc/locale.gen
printf "Wich language you have uncommented?
Type EXACTLY what you have uncommented (E.g: 'en_US.UTF-8')


"
read language
echo LANG=$language > /etc/locale.conf
printf "Type wich keymap you use: (E.g: 'br-abnt2')"
read keymap
echo KEYMAP=$keymap > /etc/vconsole.conf


# Configuring hostname
echo "Type wich hostname you want:"
read hostvar
echo $hostvar > /etc/hostname

# Installing and configuring Wi-fi/ethernet
printf "
Do you have an Wireless board and want to install Wi-fi drivers?
Type 'yes' or 'no'"
read option

# Verify the option and install or not wpa and enable dhcpcd
if [ "$option" = "yes" ]
then
    pacman -Syu
    pacman -S wireless_tools wpa_supplicant wpa_actiond dialog
    systemctl enable dhcpcd
else
    systemctl enable dhcpcd
fi

# Create an new initial RAM disk
mkinitcpio -p linux

# Configure root password
echo "Type your ROOT password: "
echo " "
passwd


# Enable multilib
printf "
Scroll down and removes the '#' in multilib
and left like this:

[multilib]
Include = /etc/pacman.d/mirrorlist


Exit using 'CTRL + O' and 'CTRL + X'
"
nano /etc/pacman.conf
pacman -Syu

# Enable intel microcode updates
printf "
Do you have an Intel CPU?
Type 'yes' or 'no'"
read intelOption
if [ "$intelOption" = "yes" ]
then
	pacman -S intel-ucode
	grub
else
	grub
fi

function grub(){
	pacman -S grub os-prober
	grub-install --target=i386-pc /dev/sda
	grub-mkconfig -o /boot/grub/grub.cfg
}

# Creating username and adding to groups
echo "Wich username you want? Type above:"
read usrname
useradd -m -g users -G wheel -s /bin/bash $usrname
printf "
Type an password for you user account:
"
passwd $usrname
groupadd adbusers
usermod -aG adm,ftp,games,http,log,rfkill,sys,systemd-journal,users,uucp,audio,disk,floppy,input,optical,scanner,storage,video,adbusers $usrname

# Installing fonts for better rendering
pacman -S $(pacman -Ss ttf | grep -v ^” ” | awk ‘{print $1}’) && fc-cache

# Installing and enabling notebook battery service
pacman -S acpi acpid
systemctl enable acpid.service 

# Installing X.Org and 3D drivers
pacman -S xorg-xinit xorg-utils xorg-server xorg-server-utils xorg-twm xorg-xclock mesa

# Installing video drivers
printf "
You have 'ati/amd', 'nvidia' or 'intel' graphics card?
type 'ati', 'nvidia' or 'intel':"
read gdrivers

if [ "$gdrivers" = "ati" ]
then
    pacman -S xf86-video-ati
elif [ "$gdrivers" = "nvidia" ]
then
    pacman -S nvidia
else
    pacman -S xf86-video-intel mesa-demos
fi

# Check if is an Virtual Machine
printf "
Are you using Virtual Machine right now?
Type 'yes' or 'no'
"
read vmachine

if [ "$vmachine" = "yes" ]
then
    pacman -S xf86-video-vesa
fi

# Installing Touchpad, Mouse and Keyboard
pacman -S xf86-input-synaptics xf86-input-mouse xf86-input-keyboard

# Add user to sudoers
printf "
Go to line that have 'ALL=(ALL) ALL' and add above this line type:

$usrname ALL=(ALL) ALL

"
pause
nano /etc/sudoers

# Graphical Environment
