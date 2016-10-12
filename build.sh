#!/bin/bash

 # Copyright � 2016, axxx007xxxz
 # Copyright � 2016, Sultan Qasim Khan <sultanqasim@gmail.com> 		      
 # Copyright � 2016, Varun Chitre  <varun.chitre15@gmail.com>	
 #
 # Custom build script
 #
 # This software is licensed under the terms of the GNU General Public
 # License version 2, as published by the Free Software Foundation, and
 # may be copied, distributed, and modified under those terms.
 #
 # This program is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # GNU General Public License for more details.
 #
 # Please maintain this if you use this script or any part of it

BUILD_START=$(date +"%s")
nocol='\033[0m'
blue='\033[0;34m'
brown='\033[0;33m'
cyan='\033[0;36m'
green='\033[0;32m'
lightblue='\033[1;34m'
red='\033[0;31m'
if [[ "$1" = "--help" || "$1" = "-h" ]]
		then
			echo "Usage: ./build.sh -jx"
			echo "x is number of jobs."
			exit
	elif [[ "$1" == "-j"* ]]
		then
			jobs="${1}"
	elif [ -z "$1" ]
		then
			jobs="-j`cat /proc/cpuinfo |grep -c "processor"`"
	else
			echo "Error!"
			echo "Run with --help or -h for options list."
			exit
fi
echo -e "${blue}Setting up${nocol}"
export ARCH=arm
export SUBARCH=arm
export CROSS_COMPILE=$(xdg-user-dir)/tools/ubertc-arm-eabi-4.9/bin/arm-eabi-
kernelname="Test"
kernelversion="2"
kernelrevision="1"
echo
echo -e "${blue}Cleaning${nocol}"
make ${jobs} mrproper
rm -f arch/arm/boot/dts/*.dtb
rm -f arch/arm/boot/dt.img
rm -fr tmp
rm -f flash/zImage
rm -f flash/dt.img
rm -fr flash/modules/*
rm -f ${kernelname}_v*.zip
echo
echo
echo -e "${lightblue}Compiling ${kernelname} Kernel${nocol}"
echo
echo -e "${blue}Initializing defconfig${nocol}"
make test-lux_defconfig
echo
echo -e "${blue}Building kernel${nocol}"
make ${jobs} zImage
make ${jobs} dtbs
echo
echo -e "${blue}Generating master DTB${nocol}"
tools/dtbToolCM -o arch/arm/boot/dt.img -s 2048 -p scripts/dtc/ arch/arm/boot/dts/
echo
echo -e "${blue}Building modules${nocol}"
make ${jobs} modules
echo
echo -e "${blue}Making flashable zip${nocol}"
mkdir -p tmp/system
make ${jobs} modules_install INSTALL_MOD_PATH=tmp/system INSTALL_MOD_STRIP=1
mkdir -p tmp/flash/modules/pronto
find tmp/system/ -name '*.ko' -type f -exec cp '{}' tmp/flash/modules/ \;
mv tmp/flash/modules/wlan.ko tmp/flash/modules/pronto/pronto_wlan.ko
mv arch/arm/boot/zImage flash/
mv arch/arm/boot/dt.img flash/
cp -r tmp/flash/modules/* flash/modules/
cd flash/
zip -qr ../${kernelname}_v${kernelversion}_r${kernelrevision}.zip * -x .gitignore
cd ../
echo
echo
echo
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$(tput bold)${cyan}Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds!${nocol}$(tput sgr0)"
