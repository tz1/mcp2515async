#!/bin/sh
# kernel hash
HASH=16eb921a96db3dc3555a65b53b99c15753e6b770
# /proc/config.gz from the pi
CONFIGZ=~/pi.config.gz

export BASEDIR=~/raspi


mkdir $BASEDIR
cd $BASEDIR
mkdir $BASEDIR/modules
git clone --depth 250 https://github.com/raspberrypi/linux.git
git clone https://github.com/msperl/spi-config
git clone https://github.com/tz1/mcp2515async
git clone https://github.com/notro/spi-bcm2708.git
git clone git://github.com/raspberrypi/tools.git
export CCDIR=$BASEDIR/tools/arm-bcm2708/arm-bcm2708-linux-gnueabi/bin
export CCPREFIX=$CCDIR/arm-bcm2708-linux-gnueabi-
export KERNEL_SRC=$BASEDIR/linux
export MODULES_TEMP=$BASEDIR/modules
cd $KERNEL_SRC

git checkout $HASH
zcat $CONFIGZ > .config
zcat $BASEDIR/linux-mcp2515-20101018.patch.gz | patch

###PATCH
patch <<'EOF'
--- ../piconfig	2014-02-13 18:48:51.937533769 -0800
+++ .config	2014-02-13 18:50:53.162250865 -0800
@@ -922,6 +922,7 @@
 CONFIG_NET_EMATCH_U32=m
 CONFIG_NET_EMATCH_META=m
 CONFIG_NET_EMATCH_TEXT=m
+# CONFIG_NET_EMATCH_CANID is not set
 CONFIG_NET_EMATCH_IPSET=m
 CONFIG_NET_CLS_ACT=y
 CONFIG_NET_ACT_POLICE=m
@@ -975,7 +976,35 @@
 CONFIG_BAYCOM_SER_FDX=m
 CONFIG_BAYCOM_SER_HDX=m
 CONFIG_YAM=m
-# CONFIG_CAN is not set
+CONFIG_CAN=m
+CONFIG_CAN_RAW=m
+CONFIG_CAN_BCM=m
+# CONFIG_CAN_GW is not set
+
+#
+# CAN Device Drivers
+#
+CONFIG_CAN_VCAN=m
+# CONFIG_CAN_SLCAN is not set
+CONFIG_CAN_DEV=m
+CONFIG_CAN_CALC_BITTIMING=y
+# CONFIG_CAN_LEDS is not set
+# CONFIG_CAN_AT91 is not set
+CONFIG_CAN_MCP251X=m
+# CONFIG_CAN_SJA1000 is not set
+# CONFIG_CAN_C_CAN is not set
+# CONFIG_CAN_CC770 is not set
+
+#
+# CAN USB interfaces
+#
+# CONFIG_CAN_EMS_USB is not set
+# CONFIG_CAN_ESD_USB2 is not set
+# CONFIG_CAN_KVASER_USB is not set
+# CONFIG_CAN_PEAK_USB is not set
+# CONFIG_CAN_8DEV_USB is not set
+# CONFIG_CAN_SOFTING is not set
+CONFIG_CAN_DEBUG_DEVICES=y
 CONFIG_IRDA=m
 
 #
EOF

# Build the linux kernel and modules

ARCH=arm CROSS_COMPILE=${CCPREFIX} make oldconfig
ARCH=arm CROSS_COMPILE=${CCPREFIX} make -j 3
ARCH=arm CROSS_COMPILE=${CCPREFIX} INSTALL_MOD_PATH=${MODULES_TEMP} make modules_install

# Build the auxillary modules

cd $BASEDIR/mcp2515async
ARCH=arm CROSS_COMPILE=${CCPREFIX} make KDIR=$KERNEL_SRC
ARCH=arm CROSS_COMPILE=${CCPREFIX} INSTALL_MOD_PATH=${MODULES_TEMP} make KDIR=$KERNEL_SRC install
cd $BASEDIR/spi-config
ARCH=arm CROSS_COMPILE=${CCPREFIX} make KDIR=$KERNEL_SRC
ARCH=arm CROSS_COMPILE=${CCPREFIX} INSTALL_MOD_PATH=${MODULES_TEMP} make KDIR=$KERNEL_SRC install
cd $BASEDIR/spi-bcm2708
ARCH=arm CROSS_COMPILE=${CCPREFIX} make KDIR=$KERNEL_SRC
ARCH=arm CROSS_COMPILE=${CCPREFIX} INSTALL_MOD_PATH=${MODULES_TEMP} make KDIR=$KERNEL_SRC install

rm ${MODULES_TEMP}/lib/modules/3.10.25+/kernel/drivers/spi/spi-bcm2708.ko

# Pack the files

cd $MODULES_TEMP
tar -cjf $BASEDIR/rpi-can-modules.tar.bz2 *
