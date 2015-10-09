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

lunch ${BUILD_INFO}_${TARGET_NAME}-${BUILD_TYPE}

if [ ${TARGET_NAME} = "hammerhead" ]; then
    VENDOR_NAME="lge"
elif [ ${TARGET_NAME} = "flo" ]; then
    VENDOR_NAME="asus"
elif [ ${TARGET_NAME} = "shamu" ]; then
    VENDOR_NAME="moto"
elif [ ${TARGET_NAME} = "flounder" ]; then
    VENDOR_NAME="htc"
fi

cd device/${VENDOR_NAME}/${TARGET_NAME}/
./extract-files.sh
cd -

make otapackage -j${PARALLEL_NUM}
