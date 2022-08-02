#!/bin/bash
test -f oe-init-build-env && source oe-init-build-env
test -f ../scripts/lkft-add-bblayers.sh && bash ../scripts/lkft-add-bblayers.sh
test -f ../scripts/lkft-add-local-conf.sh && bash ../scripts/lkft-add-local-conf.sh conf/local.conf
