#!/bin/bash
# https://vpn.ac/knowledgebase/45/IP-leak-protection.html

DEFGW=`netstat -rn | grep -Eo '0.0.0.0(\s*)(([0-9]*\.){3}[0-9]*)(\s*)0.0.0.0' | sed 's/0.0.0.0\s*//g'`

if [[ -z "$var" ]];
 then
  route del -net 0.0.0.0 netmask 0.0.0.0 gw $DEFGW
fi

exit 0
