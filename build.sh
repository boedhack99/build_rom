#!/bin/bash
WORKSPACE=~/android
ROM_SOURCE=git://github.com/LineageOS/android.git
BRANCH=lineage-18.1
DEVICE_CODE=mojito
DEVICE_MANUFACTURER=xiaomi
DEVICE_SOURCE=https://github.com/boedhack99/dxm.git -b R
VENDOR_SOURCE=https://https://github.com/boedhack/vendor_mojito.git -b R
KERNEL_SOURCE=https://https://github.com/PixelExperience-Devices/kernel_xiaomi_mojito.git -b eleven
DT_DIR=device/$DEVICE_MANUFACTURER/$DEVICE_CODE
VT_DIR=vendor/$DEVICE_MANUFACTURER/$DEVICE_CODE
KT_DIR=kernel/$DEVICE_MANUFACTURER/$DEVICE_CODE
GIT_USER_NAME=boedhack99
GIT_USER_EMAIL={$GITMAIL}
GIT_COLOR_UI=false
###################################################################################
git config --global user.name $GIT_USER_NAME
git config --global user.email $GIT_USER_EMAIL
git config --global color.ui $GIT_COLOR_UI

java -version
update-java-alternatives

if [ ! -d ~/bin ]; then
    echo "[I] Setting up repo !"
    mkdir ~/bin
fi

PATH=~/bin:$PATH
source ~/.bashrc
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo

if [ ! -d $WORKSPACE ]; then
    echo "[I] Setting up ROM source !"
    mkdir -p $WORKSPACE
fi

cd $WORKSPACE
repo init --depth=1 -u $ROM_SOURCE -b $BRANCH
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j$(nproc --all) >log 2>&1

if [ ! -d $DT_DIR ]; then
    echo "[I] Setting up device tree !"
    mkdir -p $DT_DIR
    git clone $DEVICE_SOURCE $DT_DIR
    mkdir -p $VT_DIR
    git clone $VENDOR_SOURCE $VT_DIR
    mkdir -p $KT_DIR
    git clone $KERNEL_SOURCE $KT_DIR
fi
echo "[I] Preparing for build !"
. build/envsetup.sh
brunch lineage_$DEVICE_CODE-userdebug
echo "[I] Build started !"
export SKIP_ABI_CHECKS=true 
export SKIP_API_CHECKS=true
make sepolicy
curl --upload-file ./out/target/product/mojito/test1.zip https://transfer.sh/test.zip
