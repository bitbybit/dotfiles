#!/bin/sh

#
# ~/.xsession
#
# Executed by xdm/gdm/kdm at login
#

#/bin/bash --login -i ~/.xinitrc
#ck-launch-session dbus-launch /bin/bash --login -i ~/.xinitrc

dbus-launch /bin/bash --login -i ~/.xinitrc
