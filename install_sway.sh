#!/usr/bin/bash
set -e
if [ $(id -u) -eq 0 ]; then
	echo "Please execute this script as a regular user."
	exit 1
fi
#### Sway

function reconfig_meson() {
	if [ -d build ]; then
		sudo rm -r build/meson-logs &&
		meson setup --prefix=/usr --buildtype=release build --wipe
	else
		meson setup --prefix=/usr --buildtype=release build
	fi
}

## Installing misc
#sudo apt install -y apt-add-repository apt-file mlocate
#sudo apt-file update
#sudo updatedb

## deps
# fish 


[ ! -d sway ] && git clone https://github.com/swaywm/sway.git
cd sway
[ ! -d subprojects/wayland ] && git clone https://gitlab.freedesktop.org/wayland/wayland.git subprojects/wayland
[ ! -d subprojects/wayland-protocols ] && git clone https://gitlab.freedesktop.org/wayland/wayland-protocols.git subprojects/wayland-protocols
[ ! -d subprojects/libdrm ] && git clone https://gitlab.freedesktop.org/mesa/drm.git subprojects/libdrm
[ ! -d subprojects/seatd ] && git clone https://git.sr.ht/~kennylevinsen/seatd subprojects/seatd
[ ! -d subprojects/wlroots ] && git clone https://gitlab.freedesktop.org/wlroots/wlroots.git subprojects/wlroots

reconfig_meson 
#ninja -C build &&
#sudo ninja -C build install
