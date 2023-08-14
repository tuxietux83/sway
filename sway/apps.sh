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
	firefox-esr
	thunar
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
	mako-notifier
	fonts-font-awesome
	gtk-theme-switch
	libnotify-bin
	wofi
	qt6-wayland
	qtwayland5
	usermode

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

#sudo apt install -y "${build[@]}"
sudo apt install -y "${apps[@]}"
#sudo apt install -y xmlto --no-install-recommends
#sudo apt install -y gdm3 --no-install-recommends
sudo systemctl enable acpid
sudo systemctl enable avahi-daemon

