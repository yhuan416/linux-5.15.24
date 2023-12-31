#!/bin/sh
# script-name: build.sh
# version: 1.0
# date: 2023-04-08
# author: alientek
#本脚本用作编译ATK-DLM135的Linux脚本
#

make distclean #清除编译
make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabihf- stm32mp1_atk_defconfig #选择配置文件为stm32mp1_atk_defconfig

#编译内核
make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabihf- uImage vmlinux dtbs LOADADDR=0xC2000040 -j4

#编译内核模块
make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabihf- modules -j16

#在当前目录下新建一个tmp目录，用于存放编译后的目标文件
if [ ! -e "./tmp" ]; then
    mkdir tmp
fi
rm -rf tmp/*

#将编译好的模块安装到tmp目录，通过INSTALL_MOD_STRIP=1移除模块调试信息
make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabihf- modules_install INSTALL_MOD_PATH=tmp INSTALL_MOD_STRIP=1
#删除模块目录下的source目录
rm -rf tmp/lib/modules/5.15.24/source
#删除模块的目录下的build目录
rm -rf tmp/lib/modules/5.15.24/build

#跳转到模块目录
cd tmp/lib/modules
#压缩内核模块
tar -jcvf ../../modules.tar.bz2 .
cd -
rm -rf tmp/lib

#拷贝uImage到tmp目录
cp arch/arm/boot/uImage tmp

#拷贝所有编译的设备树文件到当前的tmp目录下
cp arch/arm/boot/dts/stm32mp135d-atk*.dtb tmp

echo "编译完成请查看tmp目录"

