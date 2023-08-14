#!/usr/bin/bash
sleep 1
pkill -f xdg-desktop-portal
pkill -f xdg-desktop-portal-wlr
pkill -f xdg-desktop-portal-hyprland
/usr/libexec/xdg-desktop-portal &
sleep 2
/usr/libexec/xdg-desktop-portal-wlr &
sleep 2

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

