#!/bin/bash

BBL_CONF="conf/bblayers.conf"

bbl_list() {
  lin=$(grep -En "^BBLAYERS\ \?=\ \"\ \\\\$" "${BBL_CONF}" | cut -d: -f1)
  if [ -n "${lin}" ]; then
    linuno=$((lin + 1))
    nextsec=$(tail -n +${linuno} "${BBL_CONF}" | grep -n "^\ \ \"$" | cut -d: -f1 | head -n1)
    if [ -n "${nextsec}" ]; then
      hasta=$((nextsec - 2))
      tail -n +${linuno} "${BBL_CONF}" | head -n ${hasta} | tr -d '\\$'
    else
      tail -n +${linuno} "${BBL_CONF}" | tr -d '\\$'
    fi
  fi
}

bbl_add() {
  if ! bbl_list | grep -q "$1"; then
    if command -v bitbake-layers > /dev/null; then
      bitbake-layers add-layer "$@"
    else
      echo "Cannot find bitbake-layers." >&2
      exit 1
    fi
  fi
}

bbl_add ../meta-lkft/meta ../meta-lkft/meta-lkft-testsuites
bbl_add ../meta-openembedded/meta-networking ../meta-openembedded/meta-filesystems ../meta-openembedded/meta-oe ../meta-openembedded/meta-python
bbl_add ../meta-clang
bbl_add ../meta-qcom
bbl_add ../meta-arm/meta-arm-bsp ../meta-arm/meta-arm ../meta-arm/meta-arm-toolchain
bbl_add ../meta-intel
bbl_add ../meta-freescale
bbl_add ../meta-ti
bbl_add ../meta-96boards
bbl_add ../meta-raspberrypi
