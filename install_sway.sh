#!/usr/bin/bash
set -e
## List of packages
apps=(
	[title]="Applications"
	dunst
	firefox-est
	geany
	kitty
	mpv
	thunar
	udiskie
	wofi
)
appeareance=(
	[title]="appeareance"
	gnome-icon-theme
	tango-icon-theme
	arc-theme
	breeze-gtk-theme
	breeze-icon-theme
	breeze-cursor-theme
)
nwg_look=(
	[title]="nwg-look"
	libwebkit2gtk-4.0-dev
)
audio=(
	[title]="audio"
	pipewire-audio
	pavucontrol
	pulseaudio-utils
	pasystray
	wireplumber
)
video=(
	[title]="Video"
	intel-media-va-driver
	intel-gpu-tools
)
fonts=(
	[title]="Fonts"
	fonts-jetbrains-mono
	fonts-font-awesome
	xfonts-terminus	
)
network=(
	[title]="Network"
	network-manager-gnome
	wireless-tools
	wpasupplicant
)
libs_gtk_qt=(
	[title]="QT-GTK_Libs"
	qtwayland5
	qt6-wayland
	qt5ct
)
build=(
	[title]=Build-Essentials
 	build-essential
  	golang
)
system=(
	[title]="System"
	acpi
	acpid
	avahi-daemon
	libnotify-bin
	libinput-bin
	libinput-tools
	gvfs-fuse
	gvfs-backends
	rsync
	vainfo
	polkit-kde-agent-1
	xdg-desktop-portal
	xdg-desktop-portal-gtk
	xdg-desktop-portal-wlr
)
sway=(
	[title]="Sway"
	sway
	swawidle
	swaylock
	sway-backgrounds
	swaybg
	libwlroots10
)

PKG_LIST=( "${apps[*]}" "${appeareance[*]}" "${nwg_look[*]}" "${audio[*]}"\
	"${video[*]}" "${fonts[*]}" "${network[*]}" "${libs_gtk_qt[*]}"\
	"${build{[*]}" "${system[*]}" "${sway[*]}" )
	
## Misc
sudo apt-get update
sudo apt-get install -y apt-file mlocate software-properties-common
sudo apt-file update
sudo updatedb
sudo apt-add-repository -y "non-free contrib"

# Colors
default=$(tput sgr0)
black=$(tput setaf 0)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
white=$(tput setaf 7)
bold=$(tput bold)

# Info
action="[${green}ACTION${default}]"
question="[${cyan}QUESTION${default}]"
info="[${blue}INFO${default}]"

# Check if is running as user
if [[ $EUID == 0 ]]; then
    echo -e "${info}: ${green}Please dont run as ${red}ROOT${green}!${default}"
    exit 1
fi

while true; do
# Nala or apt-get
echo
echo "${question}: ${green}What package manager would you like to use${default}:"
echo
echo "1: ${yellow}nala ${default}- ${cyan}apt-get ${green}but more fancy${default}"
echo "2: ${yellow}apt-get${default}"
echo
read -p "${action}: ${cyan}Select option${default}: " option
case $option in
	1)
		if ! command -v nala &>/dev/null; then
			sudo apt-get update
			sudo apt-get install -y nala
			pkg_mngr="nala"
			echo -e "${action}: ${yellow}nala${default}: ${green}installed ok${default}!"
		else
			sudo apt-get update
			pkg_mngr="nala"
		fi
		break
		;;
	2)
		sudo apt-get update
		pkg_mngr="apt-get"
		echo -e "${info}: ${yellow}apt-get${default}: ${green}ok${default}!"
		break
		;;
	*)
		echo -e "${info}: ${red}Invalid option${default}!"
		;;
esac
done

### Installing ...
for installs in "${PKG_LIST[@]}"; do
var_apps=$(echo "$installs" | cut -d' ' -f1)
var_install=$(echo "$installs" | cut -d' ' -f2-)
echo
echo -e "${info} :${yellow} List of${green} $var_apps${default} :\n ${default}$var_install${default}"
read -p "${action}: ${green}Press${default} ENTER${green} to continue or ${red}Ctrl${default}+${red}c ${green}to abort${default} ..."
#sudo "$pkg_mngr" install $var_install --no-install-recommends
done

# make install dir
echo -e "${info} :${yellow} Creating${default} install${yellow} directory and${default} cd${yellow} in to${default}"
[ ! -d install ] && mkdir -v install
cd install

# nwg-look (lxapeareances with steroids)
echo -e "${info} :${yellow} Clonning git repository of${default} nwg-look${default}"
[ ! -d nwg-look ] && git clone https://github.com/nwg-piotr/nwg-look.git
cd nwg-look
echo -e "\n [INFO]: i'm not STUCK! i just need time to build myself ... (o_O)\n"
make build
read -p "Config passed ok?!"
sudo make install
cd ../..

# Cleaning git
echo -e "${info} :${yellow} Removing${default} install${yellow} directory${default}"
[ -d install ] && rm -rfv "install/"

## Post install
sudo systemctl enable acpid.service
sudo systemctl enable avahi-daemon.service

# Getting the config files from git
[ ! -d dot ] && git clone http://github.com/tuxietux83/dot.git
# Adding user to group input
if ! groups $USER | grep &>/dev/null "\binput\b";then
    sudo usermod -a -G input $USER
    echo -e "${action} :${yellow} User${green} $USER${yellow} added to${default} INPUT${yellow} group${default}"
else
    echo -e "${info} :${yellow} User${green} $USER${yellow} already added to${default} INPUT${yellow} group${default}"
fi

date_tag=$(date +"%Y%m%d%H%M")
while true; do
echo -e "${info} :${yellow}This script depends on config provided in${default} dot${yellow} folder${default}"
echo -e "${info} :${yellow}Your original${green} configs${yellow} will be backed up in${default} $HOME/.config/backup/${default}"
read -p "${action} :${green} Y${default} /${green} y${yellow} or${red} N${default} /${red} n${default} :" backup
case $backup in
	Y|y)
	source_dir="dot/config"
	dest_dir="$HOME/.config/backup/${date_tag}"
	echo -e "BackingUp to: $HOME/.config/backup/${date_tag}"
	mkdir -pv "$HOME/.config/backup/${date_tag}"
	directories=($(ls -1 "$source_dir"))
		for dir in "${directories[@]}"; do
    		mv_dir="$HOME/.config/$dir"
    		if [ -d "$mv_dir" ];then
				mv -v "$mv_dir" "$dest_dir"
			fi
		done
	rsync -av "$source_dir/" "$HOME/.config/"
	rsync -av "dot/bin/" "$HOME/bin/"
	chmod +x "$HOME/bin"/*
	ls -al "$HOME/bin"
	echo -e "${info} :${green} Done${default}!"
	exit 0
	;;
	N|n)
	echo -e "${info} :${yellow} Nothing to do${default} ."
	exit 0
	;;
	*)
	echo -e "${action} :${red} Invalid option ${magenta} $backup${default} !"
	;;
esac
done
