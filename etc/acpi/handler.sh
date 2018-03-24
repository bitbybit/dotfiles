#!/bin/sh
# Default acpi script that takes an entry for all actions

# NOTE: This is a 2.6-centric script.  If you use 2.4.x, you'll have to
#       modify it to not use /sys

set $*

STATE=`cat /sys/class/power_supply/BAT0/status`
NOW=`cat /sys/class/power_supply/BAT0/energy_now`
FULL=`cat /sys/class/power_supply/BAT0/energy_full`
FLOAT=`awk "BEGIN { print $NOW/$FULL*100 }" ;`
INT=${FLOAT/\.*}

# List of modules to unload, space seperated. Edit depending on your hardware and preferences.
modlist="uvcvideo"

# Bus list for runtime pm.
buslist="pci i2c spi"

case "$1" in
    button/power)
        #echo "PowerButton pressed!">/dev/tty5
        case "$2" in
            PBTN|PWRF)  logger "PowerButton pressed: $2" ;;
            *)          logger "ACPI action undefined: $2" ;;
        esac
        ;;
    button/sleep)
        case "$2" in
            SLPB)
		#echo -n mem >/sys/power/state
		#/usr/sbin/pm-hibernate
	    ;;
            *)      logger "ACPI action undefined: $2" ;;
        esac
        ;;
    ac_adapter)
        case "$2" in
            AC|AC*|ACAD|ADP0)
                case "$4" in
                    00000000)

			# BATTERY

			#DISPLAY=:0.0
			#/usr/bin/notify-send 'bat';

			# Enable laptop mode
			echo 5 > /proc/sys/vm/laptop_mode
			# Less VM disk activity. Suggested by powertop
			echo 1500 > /proc/sys/vm/dirty_writeback_centisecs
			# Intel power saving
			echo Y > /sys/module/snd_hda_intel/parameters/power_save_controller
			echo 1 > /sys/module/snd_hda_intel/parameters/power_save
			# Set backlight brightness to 50%
			echo 5 > /sys/class/backlight/acpi_video0/brightness
			# USB powersaving
			for i in /sys/bus/usb/devices/*/power/autosuspend; do
				echo 1 > $i
			done
			# SATA power saving
			for i in /sys/class/scsi_host/host*/link_power_management_policy; do
				echo min_power > $i
			done
			# Disable hardware modules to save power
			for mod in $modlist; do
				grep $mod /proc/modules >/dev/null || continue
				modprobe -r $mod 2>/dev/null
			done

			# Enable runtime power management. Suggested by powertop.
			for bus in $buslist; do
				for i in /sys/bus/$bus/devices/*/power/control; do
					echo auto > $i
				done
			done

			# if you move your laptop around as lower values park the heads more often and reduce the chance
			# of damage to your hard disk while it is being moved
			hdparm -B 128 /dev/sda

			# позволяет использовать энергосберегающий режим работы процессора в случае, если у того более одного ядра, благодаря особому распределению нагрузки между ядрами.
			echo 1 > /sys/devices/system/cpu/sched_mc_power_savings
			# максимальный размер памяти (в процентах), для хранения грязных данных прежде чем процесс, их сгенерировавший, будет принужден записать их
			# echo 90 > /proc/sys/vm/dirty_ratio
			# минимальное число памяти (в процентах), где позволено хранить гразные данные вместо записи на диск. Этот параметр должен быть намного меньше чем dirty_ratio
			echo 1 > /proc/sys/vm/dirty_background_ratio

			# VIDEO
			echo profile > /sys/class/drm/card0/device/power_method
			echo "low" > /sys/class/drm/card0/device/power_profile

			echo "powersave" >/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
			echo "powersave" >/sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
			echo "powersave" >/sys/devices/system/cpu/cpu2/cpufreq/scaling_governor

			echo powersave > /sys/module/pcie_aspm/parameters/policy

			# network
			ethtool -s eth0 wol d
			iwconfig wlan0 power on

                    ;;
                    00000001)

			# AC POWER

			#DISPLAY=:0.0
			#/usr/bin/notify-send 'ac';

			echo 0 > /proc/sys/vm/laptop_mode
			echo 500 > /proc/sys/vm/dirty_writeback_centisecs
			echo N > /sys/module/snd_hda_intel/parameters/power_save_controller
			echo 0 > /sys/module/snd_hda_intel/parameters/power_save
			echo 10 > /sys/class/backlight/acpi_video0/brightness
			for i in /sys/bus/usb/devices/*/power/autosuspend; do
				echo 2 > $i
			done
			for i in /sys/class/scsi_host/host*/link_power_management_policy; do
				echo max_performance > $i
			done
			for mod in $modlist; do
				if ! lsmod | grep $mod; then
					modprobe $mod 2>/dev/null
				fi
			done

        		for bus in $buslist; do
            			for i in /sys/bus/$bus/devices/*/power/control; do
                			echo on > $i
            			done
        		done

			# set it to 255 to completely disable spinning down of HDD
			hdparm -B 254 /dev/sda

			echo 0 > /sys/devices/system/cpu/sched_mc_power_savings
			#echo 40 > /proc/sys/vm/dirty_ratio
			echo 20 > /proc/sys/vm/dirty_background_ratio

			echo "default" > /sys/class/drm/card0/device/power_profile

			echo "ondemand" >/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
			echo "ondemand" >/sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
			echo "ondemand" >/sys/devices/system/cpu/cpu2/cpufreq/scaling_governor

			echo default > /sys/module/pcie_aspm/parameters/policy

			ethtool -s eth0 wol g
			iwconfig wlan0 power off

                    ;;
                esac
                ;;
            *)  logger "ACPI action undefined: $2" ;;
        esac
        ;;
    battery)

								# Auto hibernate on low battery
                # if [ "$STATE" = "Discharging" ] && [ $INT -le 3 ]; then
                #        /usr/sbin/pm-hibernate
                # fi

        case "$2" in
            BAT0)
                case "$4" in
                    00000000) #echo "offline" >/dev/tty5
                    ;;
                    00000001)   #echo "online"  >/dev/tty5
                    ;;
                esac
                ;;
            CPU0)
                ;;
            *)  logger "ACPI action undefined: $2" ;;
        esac
        ;;
    button/lid)

#case $(cat /proc/acpi/button/lid/LID0/state | awk '{print $2}') in
#    closed) vbetool dpms off ;;
#    open)   vbetool dpms on  ;;
#esac
#;;

	/usr/sbin/pm-hibernate &
	#DISPLAY=:0.0 su -c - username /usr/bin/slimlock

        #IS_ACTIVE="$( pidof /usr/bin/xscreensaver )"

        #if [ -n "$IS_ACTIVE" ]
        #then
            # run the lock command as the user who owns xscreensaver process,
            # and not as root, which won't work (see: man xscreensaver-command)
        #    su "$( ps aux | grep xscreensaver | grep -v grep | grep $IS_ACTIVE | awk '{print $1}' )" -c "/usr/bin/xscreensaver-command -lock" &
        #fi

        #echo "LID switched!">/dev/tty5
        ;;
    *)
        logger "ACPI group/action undefined: $1 / $2"
        ;;
esac
