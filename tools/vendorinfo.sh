#!/bin/bash
echo "ro.build.date=`LANG=en date`"
echo "ro.build.date.utc=`LANG=en date +%s`"
echo "ro.vendor.build.fingerprint=$BUILD_FINGERPRINT"
