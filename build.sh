#!/bin/bash

 # Copyright � 2016,  Sultan Qasim Khan <sultanqasim@gmail.com> 		      
 # Copyright � 2016,  Varun Chitre  <varun.chitre15@gmail.com>	
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
 #

#!/bin/bash
BUILD_START=$(date +"%s")
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'
export ARCH=arm
export SUBARCH=arm
export CROSS_COMPILE=/home/anderson/uber-4.9/bin/arm-eabi-
export KBUILD_BUILD_USER="anderson"
export KBUILD_BUILD_HOST="anderson@localhost-technoander"
echo -e "$nocol***********************************************"
echo "          Compiling Coffee Kernel COLOMBIA!!!!                          "   
echo -e "**********************************************$nocol"
rm -f arch/arm/boot/dts/*.dtb
rm -f arch/arm/boot/dt.img
rm -f flash_zip/boot.img
echo -e " Initializing defconfig"
make lux_defconfig
echo -e " Building kernel"
make -j4 zImage
make -j4 dtbs

/home/anderson/CoffeeKernel/tools/dtbToolCM -o /home/anderson/CoffeeKernel/arch/arm/boot/dt.img -s 2048 -p /home/anderson/CoffeeKernel/scripts/dtc/ /home/anderson/CoffeeKernel/arch/arm/boot/dts/

make -j4 modules
echo -e "$nocol*************************"
echo "          Make flashable zip              "
echo -e "*******************************$nocol"
rm -rf anderson_install
mkdir -p anderson_install
make -j4 modules_install INSTALL_MOD_PATH=anderson_install INSTALL_MOD_STRIP=1
mkdir -p flash_zip/system/lib/modules/pronto
find anderson_install/ -name '*.ko' -type f -exec cp '{}' flash_zip/system/lib/modules/ \;
mv flash_zip/system/lib/modules/wlan.ko flash_zip/system/lib/modules/pronto/pronto_wlan.ko
cp arch/arm/boot/zImage flash_zip/tools/
cp arch/arm/boot/dt.img flash_zip/tools/
rm -f /home/anderson/lux_coffeekernel_rx.zip
cd flash_zip
zip -r ../arch/arm/boot/coffeekernel.zip ./
mv /home/anderson/CoffeeKernel/arch/arm/boot/coffee_kernel.zip /home/anderson/lux_coffeekernel_rx.zip
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
