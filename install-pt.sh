#!/bin/bash

# Function for pause command
function pause(){
	read -p "Pressione [Enter] para continuar..."
}

# Shows an list of available regions
echo " "
ls /usr/share/zoneinfo
printf "
Selecione sua REGIÃO e digite abaixo:
"
read region
echo " "

# Shows an list of available cities
ls /usr/share/zoneinfo/$region/
printf " 
Selecione sua CIDADE e digite abaixo:
"
read city

# Symlink selected region and city to localtime and set time to UTC
ln -s /usr/share/zoneinfo/$region/$city /etc/localtime
hwclock --systohc --utc


# Configuring language and keymap
printf "
Você será redirecionado para editar o arquivo '/etc/locale.gen'
por favor, descomente a linha de localização brasileira.

Vá para a linha que corresponda à 'pt_BR.UTF-8' e retire o '#' antes dela.

Use 'CTRL + O' para salvar e 'CTRL + X' para sair.

"
pause
nano /etc/locale.gen
locale-gen
echo LANG=pt_BR.UTF-8 > /etc/locale.conf
echo KEYMAP=br-abnt2 > /etc/vconsole.conf
localectl set-keymap --no-convert br-abnt2


# Configuring hostname
printf "
Digite o nome de host (hostname) que você quer dar para sua máquina:
"
read hostvar
echo $hostvar > /etc/hostname

# Installing and configuring Wi-fi/ethernet
printf "
Você possui uma placa Wi-fi e quer instalar os drivers?
Digite o número correspondente:
	
	1. Sim 
	2. Não
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
Digite sua senha de ROOT:
"
passwd


# Enable multilib and install yaourt
rm -rf /etc/pacman.conf
cp pacman-conf/pacman.conf /etc/pacman.conf
pacman -Syu
pacman -S yaourt

# Enable intel microcode updates
function grub(){
	pacman -S grub os-prober
	grub-install --target=i386-pc /dev/sda
	grub-mkconfig -o /boot/grub/grub.cfg
}

printf "
Você tem um processador Intel?
Digite o número correspondente:
	
	1. Sim 
	2. Não
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
Qual usuário você quer? Digite abaixo:
"
read usrname
useradd -m -g users -G wheel -s /bin/bash $usrname
printf "
Digite uma senha para sua conta de usuário:
"
passwd $usrname
groupadd adbusers
usermod -aG adm,ftp,games,http,log,rfkill,sys,systemd-journal,users,uucp,audio,disk,floppy,input,optical,scanner,storage,video,adbusers $usrname

# Installing fonts for better rendering
pacman -S $(pacman -Ss ttf | grep -v ^” ” | awk ‘{print $1}’) && fc-cache
cp font-render/fonts.conf /home/$usrname/.config/fontconfig/fonts.conf
fc-cache --really-force

# Installing and enabling notebook battery service
pacman -S acpi acpid
systemctl enable acpid

# Installing X.Org and 3D drivers
pacman -S xorg-xinit xorg-utils xorg-server xorg-server-utils xorg-twm xorg-xclock mesa

# Installing video drivers
printf "
Você possui qual placa de vídeo? Digite o número:
	
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
Você está usando uma máquina virtual agora? 
Digite o número correspondente:
	
	1. Sim
	2. Não
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
Vá para a linha que possui 'ALL=(ALL) ALL' e digite ABAIXO dessa linha:

$usrname ALL=(ALL) ALL

"
pause
nano /etc/sudoers

# Functions to choose Graphical Environment
function gnome(){
	printf "
Você quer instalar os pacotes extras do GNOME? (gnome-extra)
Digite o número correspondente:

	1. Sim
	2. Não
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
Você quer os aplicativos do KDE? (kde-applications)
Digite o número correspondente:

	1. Sim
	2. Não
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
Você quer os aplicativos extra do Deepin? (deepin-extra)
Digite o número correspondente:

	1. Sim
	2. Não
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
Você quer os plugins extras do XFCE? (xfce4-goodies)
Digite o número correspondente:

	1. Sim
	2. Não
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
Qual ambiente gráfico você quer? Digite o número correspondente:

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
printf "
Você quer o Chromium, Firefox ou Google Chrome como seu navegador?
Digite o número correspondente:

	1. Chromium (versão de código aberto)
	2. Firefox
	3. Google Chrome
"
read browserOption
	if [ "$browserOption" = "1" ]
	then
		pacman -S chromium
	elif [ "$browserOption" = "2" ]
		pacman -S firefox
	else
		yaourt -S google-chrome --noconfirm
	fi


# Useful packages
pacman -S unrar unrace lrzip unzip p7zip alsa-lib alsa-utils nautilus-open-terminal file-roller gparted android-tools numlockx mtpfs wget ntfs-3g evince vlc qt4
yaourt -S wps-office jdk --noconfirm


# Add android rules to working adb for android devices
wget -S -O - http://source.android.com/source/51-android.rules | sed "s/<username>/$USER/" | sudo tee >/dev/null /etc/udev/rules.d/51-android.rules; sudo udevadm control --reload-rules


# Finish the script
printf "
Todos os pacotes principais foram instalados com sucesso.
Obrigado por usar esse script! Agora ele irá sair do arch-chroot.

Digite 'reboot' (sem aspas) para reiniciar e começar a usar seu novo Arch Linux!

Criado por Renan Marcos (github.com/renanmarcs)
"
pause
exit