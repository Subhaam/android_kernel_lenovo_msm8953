#!/bin/bash
BUILD_START=$(date +"%s")

# Colours
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'

# Kernel details
KERNEL_NAME="MagmaKernel"
VERSION="Freakyapples"
DATE=$(date +"%d-%m-%Y-%I-%M")
DEVICE="kuntao"
FINAL_ZIP=$KERNEL_NAME-$VERSION-$DEVICE-$DATE.zip
defconfig=magma_defconfig
THREAD="$(nproc --all)"

# Dirs
KERNEL_DIR=$(pwd)
ANYKERNEL_DIR=$KERNEL_DIR/AnyKernel2
OUT_DIR=$KERNEL_DIR/out
KERNEL_IMG=$OUT_DIR/arch/arm64/boot/Image.gz-dtb
UPLOAD_DIR=~/android/kernel/upload/$DEVICE

# Export
export ARCH=arm64
export CROSS_COMPILE=~/android/kernel/toolchain/aarch64--glibc--bleeding-edge-2018.02-1/bin/aarch64-linux-
export KBUILD_BUILD_USER="subham"
export KBUILD_BUILD_HOST="darkbox"

## Functions ##
MAKE="make O=${OUT_DIR}"

# Make kernel
function make_kernel() {
  echo -e "$cyan***********************************************"
  echo -e "          Initializing defconfig          "
  echo -e "***********************************************$nocol"
  $MAKE $defconfig
  echo -e "$cyan***********************************************"
  echo -e "             Building kernel          "
  echo -e "***********************************************$nocol"
  $MAKE -j$THREAD
  if ! [ -a $KERNEL_IMG ];
  then
    echo -e "$red Kernel Compilation failed! Fix the errors! $nocol"
  fi
}

# Making zip
function make_zip() {
mkdir -p tmp_mod
cd $OUT_DIR
$MAKE -j$THREAD modules_install INSTALL_MOD_PATH=tmp_mod
cp $KERNEL_IMG $ANYKERNEL_DIR
mkdir -p $UPLOAD_DIR
cd $ANYKERNEL_DIR
zip -r9 UPDATE-AnyKernel2.zip * -x README UPDATE-AnyKernel2.zip
mv $ANYKERNEL_DIR/UPDATE-AnyKernel2.zip $UPLOAD_DIR/$FINAL_ZIP
}

# Options
function options() {
echo -e "$cyan***********************************************"
  echo "          Compiling FireKernel kernel          "
  echo -e "***********************************************$nocol"
  echo -e " "
  echo -e " Select one of the following types of build : "
  echo -e " 1.Dirty"
  echo -e " 2.Clean"
  echo -n " Your choice : ? "
  read ch

  echo -e " Select if you want zip or just kernel : "
  echo -e " 1.Get flashable zip"
  echo -e " 2.Get kernel only"
  echo -n " Your choice : ? "
  read ziporkernel

case $ch in
  1) echo -e "$cyan***********************************************"
     echo -e "          	Dirty          "
     echo -e "***********************************************$nocol"
     make_kernel ;;
  2) echo -e "$cyan***********************************************"
     echo -e "          	Clean          "
     echo -e "***********************************************$nocol"
     $MAKE clean
     $MAKE mrproper
     rm -rf tmp_mod
     make_kernel ;;
esac

if [ "$ziporkernel" = "1" ]; then
     echo -e "$cyan***********************************************"
     echo -e "     Making flashable zip        "
     echo -e "***********************************************$nocol"
     make_zip
else
     echo -e "$cyan***********************************************"
     echo -e "     Building Kernel only        "
     echo -e "***********************************************$nocol"
fi
}

# Clean Up
function cleanup(){
rm -rf $ANYKERNEL_DIR/Image.gz-dtb
}

options
cleanup
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
