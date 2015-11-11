#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

xrdb -merge ~/.Xresources

numlockx on

mkdir -p /dev/shm/flashcookies/.macromedia/Flash_Player
mkdir -p /dev/shm/flashcookies/.adobe/Flash_Player

# setfont ter-v18n

(sleep 2s && /usr/bin/xscreensaver -no-splash) &

 ## test for an existing bus daemon, just to be safe
 if test -z "$DBUS_SESSION_BUS_ADDRESS" ; then
    ## if not found, launch a new one
    eval `dbus-launch --sh-syntax --exit-with-session`
    echo "D-Bus per-session daemon address is: $DBUS_SESSION_BUS_ADDRESS"
 fi

export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
export GDK_NATIVE_WINDOWS="1"
export QT_STYLE_OVERRIDE="GTK+"

export OPERAPLUGINWRAPPER_PRIORITY="0"
export OPERA_KEEP_BLOCKED_PLUGIN="1"

exec openbox-session
