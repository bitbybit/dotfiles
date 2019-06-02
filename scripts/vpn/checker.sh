#!/bin/sh
# http://www.linuxquestions.org/questions/linux-networking-3/check-vpn-status-900320/

#WIFIUP=`/sbin/ifconfig wlxec086b1a7b58 | grep -c "UP"`;
WIFIUP=`/sbin/ifconfig wlan1 | grep -c "UP"`;
VPNUP=`/sbin/ifconfig tun0 | grep -c "UP"`;
HOSTNAME=`/bin/hostname`;

if [ $WIFIUP != 0 ] && [ $VPNUP = 0 ];
 then
  if [ $HOSTNAME = 'hulk' ];
    then
      eval "export $(egrep -z DBUS_SESSION_BUS_ADDRESS /proc/$(pgrep -u m xfce4-session)/environ)"
  fi
  su -c 'DISPLAY=:0 notify-send "VPN disconnected"' m
fi

exit 0
