#!/bin/sh

echo "Build kernel for dlm135"

BOOTFS_PATH=${1}

INSTALL_MOD_PATH="tmp"
CPUs=`cat /proc/cpuinfo | grep processor | wc -l`

# make config
make distclean
make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabihf- stm32mp1_atk_defconfig

# make
make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabihf- uImage vmlinux dtbs LOADADDR=0xC2000040 -j${CPUs}
make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabihf- modules -j${CPUs}

# install
if [ ! -e "${INSTALL_MOD_PATH}" ]; then
    mkdir ${INSTALL_MOD_PATH}
fi
rm -rf ${INSTALL_MOD_PATH}/*
make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabihf- modules_install INSTALL_MOD_PATH=${INSTALL_MOD_PATH} INSTALL_MOD_STRIP=1

#删除模块目录下的 source/build 目录(软连接)
rm ${INSTALL_MOD_PATH}/lib/modules/5.15.24/source ${INSTALL_MOD_PATH}/lib/modules/5.15.24/build

# copy
if [ ! -e "${BOOTFS_PATH}" ]; then
    mkdir -p ${BOOTFS_PATH}
fi
rm -rf ${BOOTFS_PATH}/*

# copy to bootfs
echo "Copy to bootfs"
cp arch/arm/boot/uImage ${BOOTFS_PATH}
cp arch/arm/boot/dts/stm32mp135d-atk*.dtb ${BOOTFS_PATH}
cp -rf ${INSTALL_MOD_PATH}/lib/modules/5.15.24 ${BOOTFS_PATH}/5.15.24
