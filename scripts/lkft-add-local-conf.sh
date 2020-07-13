#!/bin/bash

replace_with() {
  if ! grep -q "^$1 = " "${LOCAL_CONF}"; then
    echo "$1 = \"$2\"" >> "${LOCAL_CONF}"
  else
    sed -i -e "s:^$1 = \".*\":$1 = \"$2\":" "${LOCAL_CONF}"
  fi
}

add_line() {
  if ! grep -q "^$*$" "${LOCAL_CONF}"; then
    echo "$*" >> "${LOCAL_CONF}"
  fi
}

if [ $# -eq 0 ]; then
  echo "$0 dir/to/local.conf" >&2
  exit 1
fi

export LOCAL_CONF="$1"

if [ ! -e "${LOCAL_CONF}" ]; then
  echo "File not found: ${LOCAL_CONF}" >&2
  exit 1
fi

if [ -v REPO_NAME ]; then
  case "${REPO_NAME}" in
    mainline)
      kernel_recipe="linux-generic-mainline"
      kernel_recipe_version="git%"
      ;;
    next)
      kernel_recipe="linux-generic-next"
      kernel_recipe_version="git%"
      ;;
    stable-rc)
      kernel_recipe="linux-generic-stable-rc"

      if [ -v GIT_BRANCH ]; then
        major_minor="$(echo "${GIT_BRANCH}" | sed -e 's#^linux-##' | cut -d\. -f1,2)"
        kernel_recipe_version="${major_minor}+git%"
      fi
      ;;
  esac
fi

replace_with IMAGE_FSTYPES_remove "ext4 iso wic wic.gz wic.bmap"
replace_with IMAGE_FSTYPES_append " ext4.gz tar.xz"
if [ -v kernel_recipe ]; then
  echo "LKFT kernel recipe:  ${kernel_recipe}"
  replace_with "PREFERRED_PROVIDER_virtual/kernel" "${kernel_recipe}"

  if [ -v kernel_recipe_version ]; then
    echo "LKFT kernel version: ${kernel_recipe_version}"
    replace_with "PREFERRED_VERSION_${kernel_recipe}" "${kernel_recipe_version}"
  fi
fi
if [ -v LATEST_SHA ]; then
  echo "LKFT kernel SHA:     ${LATEST_SHA}"
  replace_with SRCREV_kernel "${LATEST_SHA}"
  if [ -v MACHINE ]; then
    replace_with "SRCREV_kernel_${MACHINE}" "${LATEST_SHA}"
  fi
fi
add_line INHERIT += \"buildstats buildstats-summary\"
