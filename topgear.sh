#!/bin/sh

# forbid screen auto rotation
gsettings set org.gnome.settings-daemon.peripherals.touchscreen orientation-lock true

# set keyboard layout shortcut to Alt+Shift
gsettings set org.gnome.desktop.wm.keybindings switch-input-source ['<Alt>Shift_L']
gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward ['<Shift>Alt_L']

