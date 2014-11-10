#!/bin/bash

if [ $# -lt 4 ]; then
   echo "example usage: $0 target_name full_or_aosp build_type parallel_num"
   exit 1
fi

TARGET_NAME=$1
BUILD_INFO=$2
BUILD_TYPE=$3
PARALLEL_NUM=$4

source ~/bin/android-env.sh
source build/envsetup.sh
export USE_CCACHE=1
./prebuilts/misc/linux-x86/ccache/ccache -M 100G

lunch ${BUILD_INFO}_${TARGET_NAME}-${BUILD_TYPE}

if [ ${TARGET_NAME} = "mako" -o ${TARGET_NAME} = "hammerhead" ]; then
    VENDOR_NAME="lge"
elif [ ${TARGET_NAME} = "grouper" -o ${TARGET_NAME} = "flo" ]; then
    VENDOR_NAME="asus"
elif [ ${TARGET_NAME} = "manta" ]; then
    VENDOR_NAME="samsung"
elif [ ${TARGET_NAME} = "flounder" ]; then
    VENDOR_NAME="htc"
fi

if [ ${TARGET_NAME} = "mako" -o ${TARGET_NAME} = "grouper" -o ${TARGET_NAME} = "flo" -o ${TARGET_NAME} = "manta" ]; then
cd device/${VENDOR_NAME}/${TARGET_NAME}/
./download-blobs.sh
cd -
cd vendor/aosp/${VENDOR_NAME}/${TARGET_NAME}/proprietary/
rm -rf system
rm -rf *.tgz
./extract-files.sh
cd -
elif [ ${TARGET_NAME} = "hammerhead" -o ${TARGET_NAME} = "flounder" ]; then
cd device/${VENDOR_NAME}/${TARGET_NAME}/
./extract-files.sh
cd -
fi

if [ ${TARGET_NAME} = "grouper" ]; then
rm -rf vendor/nvidia/grouper/keymaster
fi

make otapackage -j${PARALLEL_NUM}
