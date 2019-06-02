#!/bin/sh

if iwgetid | grep -qs ":\"LocalNetworkName\"" && ! ping -c 1 "192.168.1.1" 2>&1 | grep -qs "100%"; then
        mount -t nfs 192.168.1.1:/opt/NFS/data /opt/data &>/dev/null
fi
