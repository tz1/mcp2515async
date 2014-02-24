#!/bin/sh
modprobe mcp2515
modprobe spi-bcm2708
modprobe can
modprobe can-dev
modprobe can-raw
modprobe can-bcm
modprobe spi-config devices=bus=0:cs=0:modalias=mcp2515:speed=10000000:gpioirq=25:pd=20:pds32-0=16000000:pdu32-4=0x2002:force_release
sleep 1
ip link set can0 type can bitrate 250000
ifconfig can0 up
candump can0 
