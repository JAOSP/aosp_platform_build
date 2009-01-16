#!/system/bin/sh

#/system/xbin/fbset -fb /dev/graphics/fb0 -a -depth 16 -rgba 5,6,5,0 -g 320 480 960 320 16
#/system/xbin/fbset -fb /dev/graphics/fb0 -a -depth 16 -rgba 5,6,5,0 -g 800 480 960 800 16

netcfg eth0 dhcp
setprop net.dns1 4.2.2.2

setprop persist.service.adb.enable 1
setprop service.adb.enable 1
echo EeeNoSleep > /sys/android_power/acquire_partial_wake_lock
