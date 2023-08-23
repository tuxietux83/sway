#!/usr/bin/bash
set -e
# Instead of lxapeareance we use nwg-look
if [ $(id -u) -eq 0 ]; then
	echo "Please execute this script as a regular user."
	exit 1
fi
# set 1 to pass without prompting
# set 0 for ptomp and running just meson setup
build_ninja="0"
#### Sway
## Misc
sudo apt-get update
sudo apt-get install -y apt-file mlocate software-properties-common
sudo apt-file update
sudo updatedb
sudo apt-add-repository -y "non-free contrib"

apps=(
	[title]="Applications"
	kitty
	pavucontrol
	pasystray
	nm-tray
	dunst
	wofi
	thunar
	udiskie
)
system=(
	[title]="System-Applications"
	acpi
	acpid
	avahi-daemon
	pipewire
	pipewire-audio
	wireplumber
	pulseaudio-utils
	intel-media-va-driver
	vainfo
	fonts-jetbrains-mono
	fonts-font-awesome
	xfonts-terminus	
	network-manager-gnome
	libnotify-bin
	gvfs-fuse
	gvfs-backends
	polkit-kde-agent-1
)
build_essentials=(
	[title]="Compiling"
	build-essential
	meson
	cmake
	ninja-build
	golang
	check
	valgrind
	hwdata
	glslang-tools
	xwayland
	scdoc
	check
	usermode
)
lib_sway=(
	[title]="Sway"
	libjson-c-dev
)
libs_gtk=(
	[title]="GTK-libs"
	libgtk-3-dev
	libgtk-4-dev
	qtwayland5
	qt6-wayland
	libwebkit2gtk-4.0-dev
	libgtk-layer-shell-dev
	qt5ct
)
libdisplay_info=(
	[title]="libdisplay-info"
	edid-decode
)
libinput=(
	[title]="libinput"
	libudev-dev
	libmtdev-dev
	libevdev-dev
	libwacom-dev
	libsystemd-dev
)
libliftoff=(
	[title]="libliftoff"
	libdrm-dev
)
wayland=(
	[title]="wayland"
	libxml2-dev
)
wayland_protocols=(
	[title]="wayland-protocols"
)
wlroots=(
	[title]="wlroots"
	libseat-dev
	libavutil-dev
	libavcodec-dev
	libavformat-dev
	libgbm-dev
	libxcb-dri3-dev
	libxcb-present-dev
	libxcb-composite0-dev
	libxcb-render-util0-dev
	libxcb-ewmh-dev
	libxcb-xinput-dev
	libxcb-icccm4-dev
	libxcb-res0-dev
)
xdg_desktop_portal_wlr=(
	[title]="Desktop-portals"
	libpipewire-0.3-dev
	libinih-dev
	xdg-desktop-portal
	xdg-desktop-portal-gtk
)
waybar=(
	[title]="Waybar"
	libfmt-dev
	libspdlog-dev
	libgtkmm-3.0-dev
	libdbusmenu-gtk3-dev
	libjsoncpp-dev
	libnl-3-dev
	libnl-genl-3-dev
	libupower-glib-dev
	libplayerctl-dev
	libpulse-dev
	libmpdclient-dev
	libxkbregistry-dev
	libjack-dev
	libwireplumber-0.4-dev
	libsndio-dev
	libfftw3-dev
	libncurses-dev
	libasound2-dev
	libportaudio-ocaml-dev
	libsdl2-dev
	clang-tidy
)

pkg_list=( "${apps[*]}" "${system[*]}" "${build_essentials[*]}" "${lib_sway[*]}"\
		"${libs_gtk[*]}" "${libdisplay_info[*]}" "${libinput[*]}" "${libliftoff[*]}" "${wayland[*]}"\
		"${wayland_protocols[*]}" "${wlroots[*]}" "${xdg_desktop_portal_wlr[*]}" "${waybar[*]}" )

# To build, we need some paths to export
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
export PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig:$PKG_CONFIG_PATH
export PKG_CONFIG_PATH=/usr/local/share/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=/usr/local/lib/:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/usr/local/lib64/:$LD_LIBRARY_PATH

for building in "${pkg_list[@]}";do
var_title=$(echo "$building" | cut -d' ' -f1)
var_apt=$(echo "$building" | cut -d' ' -f2-)
clear
echo -e "\n\nFor $var_title we need to install this packages:\n\n$var_apt\n\n"
[ "$build_ninja" = 0 ] && read -p "Hit ENTER to continue or Ctrl+c to abort"
sudo apt-get install -y $var_apt
done
clear
read -p "git time"

# make install dir
[ ! -d install ] && mkdir -v install
cd install

# libinputl git
[ ! -d libinput ] && git clone https://gitlab.freedesktop.org/libinput/libinput.git
cd libinput
[ ! -d build ] && meson setup build
[ -d build ] && meson setup build --wipe
[ "$build_ninja" = 0 ] && read -p "Config passed ok?!"
[ "$build_ninja" = 1 ] && ninja -C build
[ "$build_ninja" = 1 ] && sudo ninja -C build install
cd ..

# wlroots, libdisplay-info, libliftoff, wayland, wayland-protocols git
[ ! -d wlroots ] && git clone https://gitlab.freedesktop.org/wlroots/wlroots.git
[ ! -d wlroots/subprojects/libdisplay-info ] && git clone https://gitlab.freedesktop.org/emersion/libdisplay-info.git wlroots/subprojects/libdisplay-info
[ ! -d wlroots/subprojects/libliftoff ] && git clone https://gitlab.freedesktop.org/emersion/libliftoff.git wlroots/subprojects/libliftoff
[ ! -d wlroots/subprojects/wayland ] && git clone https://gitlab.freedesktop.org/wayland/wayland.git wlroots/subprojects/wayland
[ ! -d wlroots/subprojects/wayland-protocols ] && git clone https://gitlab.freedesktop.org/wayland/wayland-protocols.git wlroots/subprojects/wayland-protocols
cd wlroots
[ ! -d build ] && meson setup build
[ -d build ] && meson setup build --wipe
[ "$build_ninja" = 0 ] && read -p "Config passed ok?!"
[ "$build_ninja" = 1 ] && ninja -C build
[ "$build_ninja" = 1 ] && sudo ninja -C build install
cd ..

# sway, wlroots git
[ ! -d sway ] && git clone https://github.com/swaywm/sway.git
[ ! -d sway/subprojects/wlroots ] && git clone https://gitlab.freedesktop.org/wlroots/wlroots.git sway/subprojects/wlroots
cd sway
[ ! -d build ] && meson setup build
[ -d build ] && meson setup build --wipe
[ "$build_ninja" = 0 ] && read -p "Config passed ok?!"
[ "$build_ninja" = 1 ] && ninja -C build
[ "$build_ninja" = 1 ] && sudo ninja -C build install
cd ..

#XDG-desktop-portal-wlr git
[ ! -d xdg-desktop-portal-wlr ] && git clone https://github.com/emersion/xdg-desktop-portal-wlr.git
cd xdg-desktop-portal-wlr
[ ! -d build ] && meson setup build
[ -d build ] && meson setup build --wipe
[ "$build_ninja" = 0 ] && read -p "Config passed ok?!"
[ "$build_ninja" = 1 ] && ninja -C build
[ "$build_ninja" = 1 ] && sudo ninja -C build install
cd ..

# Waybar git
[ ! -d Waybar ] && git clone https://github.com/Alexays/Waybar.git
cd Waybar
# patch for hyprland
sed -i -e 's/zext_workspace_handle_v1_activate(workspace_handle_);/const std::string command = "hyprctl dispatch workspace " + name_;\n\tsystem(command.c_str());/g' src/modules/wlr/workspace_manager.cpp
# somehow iniparser needs to be in /usr/include, so let it be
[ ! -f /usr/include/iniparser.h ] && sudo ln -s -v /usr/include/iniparser/* /usr/include/
[ ! -d build ] && meson setup --auto-features=enabled build
[ -d build ] && meson setup --auto-features=enabled build --wipe
meson configure -Dexperimental=true build
[ "$build_ninja" = 0 ] && read -p "Config passed ok?!"
[ "$build_ninja" = 1 ] && ninja -C build
[ "$build_ninja" = 1 ] && sudo ninja -C build install
cd ..

# nwg-look (lxapeareances with steroids)
[ ! -d nwg-look ] && git clone https://github.com/nwg-piotr/nwg-look.git
cd nwg-look
echo -e "\n [INFO]: i'm not STUCK! i just need time to build myself ... (o_O)\n"
make build
[ "$build_ninja" = 0 ] && read -p "Config passed ok?!"
[ "$build_ninja" = 1 ] && sudo make install
cd ../..
clear
pwd
read -p "check for folder structure"
# Cleaning git 
[ -d install ] && rm -rfv "install/"

## Post install
# Getting the config files from git
[ ! -d dot ] && git clone http://github.com/tuxietux83/dot.git

sudo systemctl enable acpi
sudo systemctl enable avahi-daemon

# Adding user to group input
if ! groups $USER | grep &>/dev/null "\binput\b";then
    sudo usermod -a -G input $USER
    echo "User $USER added to INPUT group"
else
    echo "User $USER already is in group INPUT"
fi

date_tag=$(date +"%Y%m%d%H%M")
while true; do
echo -e "This script depends on config provided in dot folder"
echo -e "Your original configs will be backed up in $HOME/.config/backup/"
read -p "Y/y or N/n" backup
case $backup in
	Y|y)
	source_dir="dot/config"
	dest_dir="$HOME/.config/backup/${date_tag}"
	echo -e "${info}: ${yellow}BackingUp${default}: $HOME/.config/backup/${date_tag}"
	mkdir -pv "$HOME/.config/backup/${date_tag}"
		if [ -d "$HOME/.config/systemd" ]; then
			exclude_dir="systemd"
		else
			exclude_dir=""
		fi
	directories=($(ls -1 "$source_dir"))
		for dir in "${directories[@]}"; do
    		mv_dir="$HOME/.config/$dir"
    		if [ -d "$mv_dir" ];then
				mv -v "$mv_dir" "$dest_dir"
			fi
		done
	rsync -av "$source_dir/" "$HOME/.config"
	# adding bin files
	[ ! -d "$HOME/bin" ] && mkdir -pv "$HOME/bin"
	cp -v "$source_dir/*" "$HOME/bin"
	;;
	N|n)
	echo -e "${action} ${yellow} Nothing to do ${default}."
	exit 0
	;;
	*)
	echo -e "${info}: ${red}Invalid option${default}!"
	;;
esac
done
