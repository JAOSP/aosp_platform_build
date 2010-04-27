#!/system/bin/sh

netcfg eth0 dhcp
setprop ro.com.android.dataroaming true
setprop persist.service.adb.enable 1
setprop service.adb.enable 1
