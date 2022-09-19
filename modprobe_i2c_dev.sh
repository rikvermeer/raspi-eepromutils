#!/bin/bash
# Or try
#sudo dtoverlay i2c0

sudo modprobe i2c_dev at24
sudo sh -c 'echo "24c32 0x50" > /sys/class/i2c-adapter/i2c-0/new_device'
sudo hexdump /sys/class/i2c-adapter/i2c-0/0-0050/eeprom

# https://www.raspberrypi.org/forums/viewtopic.php?t=108134
# /proc/device-tree/hat/vendor
# /proc/device-tree/hat/product

# /proc/device-tree/name (empty)
# /proc/device-tree/model (Raspberry Pi 3 Model B Plus Rev 1.3)
# /proc/device-tree/compatible (raspberrypi,3-model-b-plusbrcm,bcm2837)
# /proc/device-tree/serial-number (00000000e13af3f1)
