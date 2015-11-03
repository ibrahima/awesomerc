#!/bin/sh

ACTION=`zenity --width=200 --height=300 --list --radiolist --text="<span font='24'>Select logout action</span>" --title="Logout" --column "Choice" --column "Action" TRUE Logout FALSE Shutdown FALSE Reboot FALSE LockScreen FALSE Suspend`

if [ -n "${ACTION}" ];then
    case $ACTION in
        Logout)
            zenity --question --text "Are you sure you want to log out?" && /usr/bin/gnome-session-quit --logout --no-prompt
            ;;
        Shutdown)
            zenity --question --text "Are you sure you want to halt?" && dbus-send --system --print-reply --dest=org.freedesktop.login1 /org/freedesktop/login1 "org.freedesktop.login1.Manager.PowerOff" boolean:true
            ;;
        Reboot)
            zenity --question --text "Are you sure you want to reboot?" && dbus-send --system --print-reply --dest=org.freedesktop.login1 /org/freedesktop/login1 "org.freedesktop.login1.Manager.Reboot" boolean:true
            ;;
        Suspend)
            #gksudo pm-suspend
            dbus-send --system --print-reply --dest=org.freedesktop.login1 /org/freedesktop/login1 "org.freedesktop.login1.Manager.Suspend" boolean:true
            ;;
        LockScreen)
            gnome-screensaver-command -l
            ;;
    esac
fi
