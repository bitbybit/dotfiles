#!/bin/sh
xrandr -o right
xinput set-prop 'Goodix Capacitive TouchScreen' 'Coordinate Transformation Matrix' 0 -1 1 1 0 0 0 0 1
