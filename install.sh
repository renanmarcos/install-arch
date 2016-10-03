#!/bin/bash

# Function for pause command
function pause(){
	read -p "Press [Enter] to proceed..."
}

# Shows an list of available regions
ls /usr/share/zoneinfo
echo " "
echo "Select your REGION and type above:"
echo " "
read region
echo " "
echo " "

# Shows an list of available cities
ls /usr/share/zoneinfo/$region/
echo " "
echo "Select your CITY and type above:"
echo " "
read city

# Symlink selected region and city to localtime and set time to UTC
ln -s /usr/share/zoneinfo/$region/$city /etc/localtime
hwclock --systohc --utc


# Configuring language and keymap
printf "
You will be redirected to edit file '/etc/locale.gen'
please, uncomment the needed localization
example: if you need 'en_US.UTF-8'... Go to line
and removes the '#' before this

Use 'CTRL + O' to save and 'CTRL + X' to exit


"
pause
nano /etc/locale.gen
locale-gen
printf "Wich language you have uncommented?
Type EXACTLY what you have uncommented (E.g: en_US.UTF-8)


"
read language
echo LANG=$language > /etc/locale.conf
printf "Type wich keymap you use: (E.g: br-abnt2)
"
read keymap
echo KEYMAP=$keymap > /etc/vconsole.conf
localectl set-keymap --no-convert $keymap


# Configuring hostname
echo "Type wich hostname you want:"
echo " "
read hostvar
echo $hostvar > /etc/hostname

# Installing and configuring Wi-fi/ethernet
printf "
Do you have an Wireless board and want to install Wi-fi drivers?
Type 'yes' or 'no'
"
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
function grub(){
	pacman -S grub os-prober
	grub-install --target=i386-pc /dev/sda
	grub-mkconfig -o /boot/grub/grub.cfg
}

printf "
Do you have an Intel CPU?
Type 'yes' or 'no'
"
read intelOption
if [ "$intelOption" = "yes" ]
then
	pacman -S intel-ucode
	grub
else
	grub
fi


# Creating username and adding to groups
echo "Wich username you want? Type above:"
echo " "
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
systemctl enable acpid

# Installing X.Org and 3D drivers
pacman -S xorg-xinit xorg-utils xorg-server xorg-server-utils xorg-twm xorg-xclock mesa

# Installing video drivers
printf "
You have 'ati/amd', 'nvidia' or 'intel' graphics card?
type ati, nvidia or intel:
"
read gdrivers

if [ "$gdrivers" = "ati" ]
then
    pacman -S xf86-video-ati
elif [ "$gdrivers" = "nvidia" ]
then
    pacman -S nvidia
    nvidia-xconfig
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
Go to line that have 'ALL=(ALL) ALL' and above this line type:

$usrname ALL=(ALL) ALL

"
pause
nano /etc/sudoers

# Functions to choose Graphical Environment
function gnome(){
	echo "Do you want extra packages from GNOME? (gnome-extra)"
	echo "type 'yes' or 'no'"
	echo " "
	read gnomeExtra
		if [ "$gnomeExtra" = "yes" ]
		then
			pacman -S gnome gnome-extra gnome-shell gdm networkmanager
			systemctl enable gdm
		else
			pacman -S gnome gnome-shell gdm networkmanager
			systemctl enable gdm
		fi
}


function kde(){
	echo "Do you want KDE Applications? (kde-applications)"
	echo "type 'yes' or 'no'"
	echo " "
	read kdeApps
		if [ "$kdeApps" = "yes" ]
		then
			pacman -S plasma kde-applications sddm networkmanager
			systemctl enable sddm
		else
			pacman -S plasma sddm networkmanager
			systemctl enable sddm
		fi
}


function deepin(){
	echo "Do you want Deepin Extra applications? (deepin-extra)"
	echo "type 'yes' or 'no'"
	echo " "
	read deepinExtra
		if [ "$deepinExtra" = "yes" ]
		then
			pacman -S deepin deepin-extra deepin-session-ui networkmanager
			ln -s /usr/bin/deepin-terminal /usr/bin/x-terminal-emulator
			systemctl enable lightdm
		else
			pacman -S deepin deepin-session-ui networkmanager deepin-terminal
			ln -s /usr/bin/deepin-terminal /usr/bin/x-terminal-emulator
			systemctl enable lightdm
		fi
}


function xfce(){
	echo "Do you want extra plugins for XFCE? (xfce4-goodies)"
	echo "type 'yes' or 'no'"
	echo " "
	read xfceExtra
		if [ "$xfceExtra" = "yes" ]
		then
			pacman -S xfce4 xfce4-goodies lightdm-gtk-greeter networkmanager
			systemctl enable lightdm
		else
			pacman -S xfce4 lightdm-gtk-greeter networkmanager
			systemctl enable lightdm
		fi
}


function lxde(){
	pacman -S lxde networkmanager
	systemctl enable lxdm
}


function choose(){
	printf "
		Wich Graphical Environment you want? Type the NUMBER that you want:

		1. Gnome
		2. KDE
		3. Deepin
		4. XFCE
		5. LXDE
				"
		read num

	case $num in
		1) gnome ;;
		2) kde ;;
		3) deepin ;;
		4) xfce ;;
		5) lxde ;;
		*) choose ;;
	esac
}

choose
systemctl enable networkmanager

# Browser option
echo "Do you want Chromium or Firefox as your browser?"
echo "type 'chromium' or 'firefox'"
echo " "
read browserOption
	if [ "$browserOption" = "chromium" ]
	then
		pacman -S chromium
	else
		pacman -S firefox
	fi


# Useful packages
pacman -S unrar unrace lrzip unzip p7zip alsa-lib alsa-utils nautilus-open-terminal file-roller gparted android-tools gnome-system-monitor numlockx mtpfs wget ntfs-3g evince vlc


# Add android rules to working adb for android devices
wget -S -O - http://source.android.com/source/51-android.rules | sed "s/<username>/$USER/" | sudo tee >/dev/null /etc/udev/rules.d/51-android.rules; sudo udevadm control --reload-rules


# Finish the script
printf "All important packages have been succefully installed.
Thanks for using this script! Now this will exit from arch-chroot.
Type 'reboot' to reboot and start using your new Arch Linux!

Created by Renan Marcos (github.com/renanmarcs)"
pause
exit