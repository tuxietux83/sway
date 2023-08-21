#!/usr/bin/bash
set -e
if [ $(id -u) -eq 0 ]; then
	echo "Please execute this script as a regular user."
	exit 1
fi
#### Sway
## Installing misc
sudo apt install -y apt-file mlocate
sudo apt-file update
sudo updatedb

apps=(
	acpi
	acpid
	avahi-daemon
	fish
	pipewire
	pipewire-audio
	wireplumber
	pavucontrol
	alsa-utils
	pasystray
	network-manager-gnome
	nm-tray
	intel-media-va-driver
	vainfo
	dunst
	fonts-font-awesome
	libnotify-bin
	wofi
)

build=(
	build-essential
	meson
	ninja-build
	cmake
	usermode
	glslang-dev
	glslang-tools
	check
	jq
	graphviz
	doxygen
	xsltproc
	libpcre2-dev
	libjson-c-dev
	libpango1.0-dev
	libcairo2-dev
	libgdk-pixbuf2.0-dev
	libxml2-dev
	libdrm-dev
	libxkbcommon-dev
	libdisplay-info-dev
	libliftoff-dev
	libxcb-dri3-dev
	libxcb-composite0-dev
	libxcb-ewmh-dev
	libxcb-present-dev
	libxcb-icccm4-dev
	libxcb-render-util0-dev
	libxcb-res0-dev
	libxcb-xinput-dev
	libsystemd-dev
	libvulkan-dev
	libegl-dev
	libgbm-dev
	libgles-dev
	libseat-dev
	libevdev-dev
	libudev-dev
	libmtdev-dev
	libwacom-dev
	libgtk-3-dev
	libgtk-4-dev
	libgtk-layer-shell-dev
	libpam0g-dev
	libxcb-xkb-dev
	qt6-wayland
	qtwayland5
	hwdata
	scdoc
	valgrind
	xwayland
)

# not sure about this, will see
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
export PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig:$PKG_CONFIG_PATH
export PKG_CONFIG_PATH=/usr/local/share/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=/usr/local/lib/:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/usr/local/lib64/:$LD_LIBRARY_PATH

sudo apt install -y "${build[@]}"
sudo apt install -y "${apps[@]}"
sudo apt install -y xmlto --no-install-recommends
#sudo apt install -y gdm3 --no-install-recommends
sudo systemctl enable acpi
sudo systemctl enable avahi-daemon
clear
read -p "git time"

### Libinput latest ok
#[ ! -d libinput ] &&  git clone https://gitlab.freedesktop.org/libinput/libinput
#cd libinput
#if [ -d build ]; then
#	sudo rm -r build/meson-logs
#	meson setup --prefix=/usr --buildtype=release build --wipe
#else
#	meson setup --prefix=/usr --buildtype=release build
#fi
#ninja -C build/ &&
#sudo ninja -C build/ install

[ ! -d ly ] && git clone --recurse-submodules https://github.com/fairyglade/ly
make
sudo make install installsystemd
sudo systemctl enable ly.service

### Wayland latest ok
[ ! -d wayland ] && git clone https://gitlab.freedesktop.org/wayland/wayland.git
cd wayland
if [ -d build ]; then
	sudo rm -r build/meson-logs
	meson setup --prefix=/usr --buildtype=release build --wipe
else
	meson setup --prefix=/usr --buildtype=release build
fi
ninja -C build/ &&
sudo ninja -C build/ install
cd ..
read -p "wayland is installed, press enter to continue ..."


[ ! -d sway ] && git clone https://github.com/swaywm/sway.git
cd sway
[ ! -d subprojects/wayland-protocols ] && git clone https://gitlab.freedesktop.org/wayland/wayland-protocols.git subprojects/wayland-protocols
[ ! -d subprojects/wlroots ] && git clone https://gitlab.freedesktop.org/wlroots/wlroots.git subprojects/wlroots
[ ! -d subprojects/libliftoff ] && git clone https://gitlab.freedesktop.org/emersion/libliftoff.git subprojects/libliftoff
[ ! -d subprojects/libinput ] && git clone https://gitlab.freedesktop.org/libinput/libinput subprojects/libinput

if [ -d build ]; then
	sudo rm -r build/meson-logs
	meson setup --prefix=/usr --buildtype=release build --wipe
else
	meson setup --prefix=/usr --buildtype=release build
fi
ninja -C build &&
sudo ninja -C build install

# Adding user to group input
if ! groups $USER | grep &>/dev/null "\binput\b";then
    sudo usermod -a -G input $USER
    echo "User $USER added to INPUT group"
else
    echo "User $USER already is in group INPUT"
fi

# Start/restart wireplumber
SERVICE_NAME="wireplumber.service"
status=$(systemctl --user is-active $SERVICE_NAME)
if [ "$status" = "active" ]; then
    echo "$SERVICE_NAME -> Running ..."
    echo "$SERVICE_NAME -> Restarting..."
    systemctl --user restart $SERVICE_NAME
    echo "$SERVICE_NAME -> Restarted ..."
elif [ "$status" = "inactive" ]; then
    echo "$SERVICE_NAME -> Inactive ..."
    echo "$SERVICE_NAME -> Starting ..."
    systemctl --user start $SERVICE_NAME
    echo "$SERVICE_NAME -> Started ..."
else
    echo "$SERVICE_NAME: $status"
    echo "Do you have wireplumber?!"
fi

