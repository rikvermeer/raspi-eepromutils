#!/bin/bash

CURDIR=${PWD}
COMMAND="${BASH_SOURCE:-$0}"
TARGET_DIR="$( cd "$(dirname $COMMAND)" ; pwd -P )"
TARGET="$(basename $COMMAND)"

# -rw------- 1 root root 4096 Jan 26 21:07 /sys/class/i2c-adapter/i2c-0/0-0050/eeprom
# dd: error writing '/sys/class/i2c-adapter/i2c-0/0-0050/eeprom': Connection timed out
# echo $? --> 1

## Autoflash
# Test if /proc/device-tree/hat does NOT exists
# Test if there is a hat attached
# - modprobe at24
# - add device
# Generate eep
# flash blank.eep
# flash eep

function probe {
  modprobe i2c_dev at24
  return $?
}

function has_hat {
  [ -d /proc/device-tree/hat ]
  return $?
}

function get_hat_uuid {
  UUID=$(tr -d '\0' </proc/device-tree/hat/uuid)
}

function has_i2c {
  i2cdetect -y 0 0x50 0x50 | grep -E '50: 50|50: UU' &> /dev/null
  return $?
}

function is_inuse_i2c {
  i2cdetect -y 0 0x50 0x50 | grep -E '50: UU' &> /dev/null
  return $?
}

function add_device {
  is_inuse_i2c && return 0
  has_i2c && sh -c 'echo "24c32 0x50" > /sys/class/i2c-adapter/i2c-0/new_device'
  return $?
}

function prepare_eeprom {
  local IN=${1:-${TARGET_DIR}/eeprom_PiPOS.txt}
  local OUT=${2:-${TARGET_DIR}/eeprom_PiPOS.eep}
  UUID=$(eepmake ${IN} ${OUT} | grep -oP 'UUID=\K(\w+|-+)*')
  return $?
}

function write_blank {
  write_eeprom blank.eep
  return $?
}

function write_eeprom {
  local IN=${1:-${TARGET_DIR}/eeprom_PiPOS.eep}
  local OUT=${2:-/sys/class/i2c-adapter/i2c-0/0-0050/eeprom}
  #dd if=${IN} of=${OUT} status=progress
  dd if=${IN} of=${OUT} status=none
  #eepflash.sh -w -f=${IN} -t=24c32 -d=0 -a=50
  return $?
}

function read_eeprom {
  local IN=${2:-/sys/class/i2c-adapter/i2c-0/0-0050/eeprom}
  local OUT=${1:-${TARGET_DIR}/dump.eep}
  dd if=${IN} of=${OUT} status=progress
  #eepflash.sh -r -f=${EEP_FILE} -t=24c32 -d=0 -a=50
  return $?
}

function install_eeprom {
  probe && has_i2c && { is_inuse_i2c || add_device; } && prepare_eeprom && write_blank && write_eeprom
}

function main {
  has_hat && { get_hat_uuid && echo ${UUID}; } || { install_eeprom && echo ${UUID}; }
}

[[ $0 != "$BASH_SOURCE" ]] || main "$@"
