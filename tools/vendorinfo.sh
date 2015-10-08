#!/bin/bash
echo "ro.vendor.build.date=`LANG=en date`"
echo "ro.vendor.build.date.utc=`LANG=en date +%s`"
echo "ro.vendor.build.fingerprint=$BUILD_FINGERPRINT"
