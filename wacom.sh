#!/bin/bash

xsetwacom --set "Wacom Bamboo 2FG 4x5 Pen stylus" Mode Relative
xsetwacom --set "Wacom Bamboo 2FG 4x5 Pen eraser" Mode Relative
#xsetwacom --set "Wacom Bamboo 2FG 4x5 Finger pad" Mode Relative
xsetwacom --set "Wacom Bamboo 2FG 4x5 Finger touch" Mode Relative

xsetwacom --set "Wacom Bamboo 2FG 4x5 Finger pad" Touch off

# http://forum.meetthegimp.org/index.php?topic=431.5;wap2
#  /usr/local/bin/xsetwacom set Pad AbsWDn "Button 5"	 # touchpad scroll up
#  /usr/local/bin/xsetwacom set Pad AbsWUp "Button 4"	 # touchpad scroll down
#  /usr/local/bin/xsetwacom set Pad Button1 "Button 1"	 # key 1 (<) click left
#  /usr/local/bin/xsetwacom set Pad Button2 "CORE KEY  SHIFT"	# key 2 (FN1) SHIFT
#  /usr/local/bin/xsetwacom set Pad Button3 "Button 3"	 # key 3 (>) click right
#  /usr/local/bin/xsetwacom set Pad Button4 "CORE KEY  CTRL"	# key 4 (FN2) CTRL

#  /usr/local/bin/xsetwacom set Stylus TPCButton "off"	 # side switch mode
#  /usr/local/bin/xsetwacom set Stylus mode "Absolute"	 # positioning mode
#  /usr/local/bin/xsetwacom set Stylus Button1 "Button 1"	# pentip click left
#  /usr/local/bin/xsetwacom set Stylus Button2 "Button 3"	# Lower side switch click right
#  /usr/local/bin/xsetwacom set Stylus Button3 "Button 2"	# Upper side switch click middle

xsetwacom --set "Wacom Bamboo 2FG 4x5 Finger pad" Button 3 "key ctrl key z"
xsetwacom --set "Wacom Bamboo 2FG 4x5 Finger pad" Button 8 "key Page_Up"
xsetwacom --set "Wacom Bamboo 2FG 4x5 Finger pad" Button 9 "key Page_Down"
xsetwacom --set "Wacom Bamboo 2FG 4x5 Finger pad" Button 1 "key alt"

xsetwacom --set "Wacom Bamboo 2FG 4x5 Pen stylus" Button 2 "key ctrl"
xsetwacom --set "Wacom Bamboo 2FG 4x5 Pen stylus" Button 3 "key ctrl key z"

#xsetwacom set "Wacom Bamboo 2FG 4x5 Finger pad" "Button" "3" "key Page_Up"
#xsetwacom set "Wacom Bamboo 2FG 4x5 Finger pad" "Button" "8" "key Home"
#xsetwacom set "Wacom Bamboo 2FG 4x5 Finger pad" "Button" "9" "key End"
#xsetwacom set "Wacom Bamboo 2FG 4x5 Finger pad" "Button" "1" "key Page_Down"
