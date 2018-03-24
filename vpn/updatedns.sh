#!/bin/bash
# https://forum.vpn.ac/discussion/13/running-openvpn-in-linux-terminal-with-no-dns-leaks

#case "$script_type" in
case "$1" in
  up)
        mv /etc/resolv.conf /etc/resolv.conf.orig
        echo "search localhost.localdomain
nameserver 8.8.8.8
nameserver 8.8.4.4" > /etc/resolv.conf
        ;;
  down)
        cp -a /etc/resolv.conf.orig /etc/resolv.conf
        ;;
esac

exit 0
