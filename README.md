mcp2515async
============

async SPI for MCP2515 to be build alongside the linux kernel i

(instead of a patch, easier for raspberry pi)

Some small mods as #defines to remove function attribute typing that doesn't work on the latest tree.

This is a fork.

Orignal code:

http://clientes.netvisao.pt/anbadeol/mcp2515.html

This doesn't build or include the can userspace tools which are at:

https://gitorious.org/linux-can/can-utils/source/110af11db13d7ab62684da5c0fd03fbb497645c9:

But there is nothing special required to build working versions of them on the pi.

Included is a build script to add CAN support to the raspian kernel.

To build the can modules, you need to find the github verson hash for the current kernel and get the /proc/config.gz file, and run the canpi.sh on a laptop or desktop, preferably a fast one.  It will fetch all the pieces and rebuild the kernel and the added modules for CAN support.

Note that if you do certain kinds of other modifications to the kernel, this will not apply.  If the modules won't load because the symbols don't match you will also have to install the new kernel in addition to the new modules.

The process for finding the hash is given toward the end of https://github.com/raspberrypi/linux/issues/486

The script will create a compressed tar that is to be copied to the pi.  It can (normally) be unpacked at /, but it is safer to unpack in a different directory (you will need sudo or to be root), move the old 3.xx.yy+ directory to 3.xx.yy.bak, and move the new 3.xx.yy+ into /lib/modules/.

The script is set for the raspian kernel as of 2/1/2014.  If the kernel is updated, the process needs to be rerun with the new config and the new hash (and the internal patch might not apply cleanly).  I plan on keeping it updated.

There is a second script to be run on the pi, startcan.sh, which will load the modules and start dumping CAN at 250000.

