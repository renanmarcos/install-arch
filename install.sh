#!/bin/bash

# Function for pause command
function pause(){
	read -p "Press [Enter] to proceed..."
}

# Select language option
	printf "
Wich language do you speak? Type the NUMBER:
Qual língua você fala? Digite o NÚMERO:

			1. English
			2. Português
			
"
		read scriptLanguage

		if [ "$scriptLanguage" = "2" ]
			then
			./install-pt.sh
		fi

# Shows an list of available regions
echo " "
ls /usr/share/zoneinfo
printf "
Select your REGION and type above:
"
read region
echo " "

# Shows an list of available cities
ls /usr/share/zoneinfo/$region/
printf " 
Select your CITY and type above:
"
read city

# Symlink selected region and city to localtime and set time to UTC
ln -s /usr/share/zoneinfo/$region/$city /etc/localtime
hwclock --systohc --utc


# Configuring language and keymap
printf "
You will be redirected to edit file '/etc/locale.gen'
please, uncomment the needed localization
example: if you need 'en_US.UTF-8'... Go to line
and removes the '#' before this.

Use 'CTRL + O' to save and 'CTRL + X' to exit.


"
pause
nano /etc/locale.gen
locale-gen
printf "
Wich language you have uncommented?
Type EXACTLY what you have uncommented (E.g: en_US.UTF-8)


"
read language
echo LANG=$language > /etc/locale.conf
export LANG=$language
printf "
Type wich keymap you use: (E.g: de-latin1)

"
read keymap
echo KEYMAP=$keymap > /etc/vconsole.conf


# Configuring hostname
printf "
Type wich hostname you want:
"
read hostvar
echo $hostvar > /etc/hostname

# Installing and configuring Wi-fi/ethernet
printf "
Do you have an Wireless board and want to install Wi-fi drivers?
Type the number:
	
	1. Yes
	2. No
"
read option

# Verify the option and install or not wpa and enable dhcpcd
if [ "$option" = "1" ]
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
printf "
Type your ROOT password:
"
passwd


# Enable multilib
rm -rf /etc/pacman.conf
cp pacman-conf/pacman.conf /etc/pacman.conf
pacman -Syu

# Install yaourt
git clone https://aur.archlinux.org/package-query.git
cd package-query
makepkg -sri
cd ..
git clone https://aur.archlinux.org/yaourt.git
cd yaourt
makepkg -sri
cd ..
rm -rf package-query
rm -rf yaourt

# Enable intel microcode updates
function grub(){
	pacman -S grub os-prober
	grub-install --target=i386-pc /dev/sda
	grub-mkconfig -o /boot/grub/grub.cfg
}

printf "
Do you have an Intel CPU?
Type the number:
	
	1. Yes
	2. No
"
read intelOption
if [ "$intelOption" = "1" ]
then
	pacman -S intel-ucode
	grub
else
	grub
fi


# Creating username and adding to groups
printf "
Wich username you want? Type above:
"
read usrname
useradd -m -g users -G wheel -s /bin/bash $usrname
printf "
Type an password for you user account:
"
passwd $usrname
groupadd adbusers
usermod -aG adm,ftp,games,http,log,rfkill,sys,systemd-journal,users,uucp,audio,disk,floppy,input,optical,scanner,storage,video,adbusers $usrname

# Installing fonts for better rendering
pacman -S $(pacman -Ss ttf | grep -v ^" " | awk '{print $1}') && fc-cache
mkdir -p /home/$usrname/.config/fontconfig
cp font-render/fonts.conf /home/$usrname/.config/fontconfig/fonts.conf
fc-cache --really-force

# Installing and enabling notebook battery service
pacman -S acpi acpid
systemctl enable acpid

# Installing X.Org and 3D drivers
pacman -S xorg-xinit xorg-utils xorg-server xorg-server-utils xorg-twm xorg-xclock mesa

# Installing video drivers
printf "
You have 'ati/amd', 'nvidia' or 'intel' graphics card?
Type the number:
	
	1. ATI/AMD
	2. Nvidia 
	3. Intel
"
read gdrivers

if [ "$gdrivers" = "1" ]
then
    pacman -S xf86-video-ati
elif [ "$gdrivers" = "2" ]
then
    pacman -S nvidia
    nvidia-xconfig
else
    pacman -S xf86-video-intel mesa-demos
fi

# Check if is an Virtual Machine
printf "
Are you using Virtual Machine right now?
Type the number:
	
	1. Yes
	2. No
"
read vmachine

if [ "$vmachine" = "1" ]
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
	printf "
Do you want extra packages from GNOME? (gnome-extra)
Type the number:
	
	1. Yes
	2. No
"
	read gnomeExtra
		if [ "$gnomeExtra" = "1" ]
		then
			pacman -S gnome gnome-extra gnome-shell gdm networkmanager
			systemctl enable gdm
		else
			pacman -S gnome gnome-shell gdm networkmanager
			systemctl enable gdm
		fi
}


function kde(){
	printf "
Do you want KDE Applications? (kde-applications)
Type the number:
	
	1. Yes
	2. No
"
	read kdeApps
		if [ "$kdeApps" = "1" ]
		then
			pacman -S plasma kde-applications sddm networkmanager
			systemctl enable sddm
		else
			pacman -S plasma sddm networkmanager
			systemctl enable sddm
		fi
}


function deepin(){
	printf "
Do you want Deepin Extra applications? (deepin-extra)
Type the number:
	
	1. Yes
	2. No
"
	read deepinExtra
		if [ "$deepinExtra" = "1" ]
		then
			pacman -S deepin deepin-extra deepin-session-ui networkmanager gnome-calculator gnome-system-monitor
			ln -s /usr/bin/deepin-terminal /usr/bin/x-terminal-emulator
			systemctl enable lightdm
		else
			pacman -S deepin deepin-session-ui networkmanager deepin-terminal
			ln -s /usr/bin/deepin-terminal /usr/bin/x-terminal-emulator
			systemctl enable lightdm
		fi
}


function xfce(){
	printf "
Do you want extra plugins for XFCE? (xfce4-goodies)
Type the number:
	
	1. Yes
	2. No
"
	read xfceExtra
		if [ "$xfceExtra" = "1" ]
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

# Temporary permission to run yaourt
mkdir /home/build
chgrp nobody /home/build
chmod g+ws /home/build
setfacl -m u::rwx,g::rwx /home/build
setfacl -d --set u::rwx,g::rwx,o::- /home/build

# Browser option
printf "
Do you want Chromium, Firefox or Google Chrome as your browser?
Type the number:

	1. Chromium (open source version)
	2. Firefox
	3. Google Chrome
"
read browserOption
	if [ "$browserOption" = "1" ]
	then
		pacman -S chromium
	elif [ "$browserOption" = "2" ]
	then
		pacman -S firefox
	else
		sudo -u nobody yaourt -S google-chrome --noconfirm
	fi


# Useful packages
pacman -S unrar lrzip unzip p7zip alsa-lib alsa-utils nautilus-open-terminal file-roller gparted android-tools numlockx mtpfs wget ntfs-3g evince vlc qt4
sudo -u nobody yaourt -S jdk --noconfirm

# Remove temporary yaourt permissions
rm -rf /home/build

# Add android rules to working adb for android devices
wget -S -O - http://source.android.com/source/51-android.rules | sed "s/<username>/$USER/" | sudo tee >/dev/null /etc/udev/rules.d/51-android.rules; sudo udevadm control --reload-rules


# Finish the script
printf "
All important packages have been succefully installed.
Thanks for using this script! Now this will exit from arch-chroot.
Type 'reboot' (without quotes) to reboot and start using your new Arch Linux!

Created by Renan Marcos (github.com/renanmarcs)
"
pause
exit