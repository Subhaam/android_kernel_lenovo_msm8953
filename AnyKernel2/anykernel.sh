# AnyKernel2 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() {
kernel.string=FireKernel by FireLord @ xda-developers
do.devicecheck=1
do.modules=1
do.cleanup=1
do.cleanuponabort=0
device.name1=p2a42
device.name2=p2
device.name3=kuntao
device.name4=kuntao_row
device.name5=P2a42
} # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=0;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. /tmp/anykernel/tools/ak2-core.sh;

## AnyKernel install
dump_boot;
write_boot;

## end install
