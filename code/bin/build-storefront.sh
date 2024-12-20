#!/bin/bash

CWD="$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

export PROJECT_ROOT="${PROJECT_ROOT:-"$(dirname $CWD)"}"
STOREFRONT_ROOT="${STOREFRONT_ROOT:-"${PROJECT_ROOT}/vendor/shopware/platform/src/Storefront"}"

# build storefront
[[ ${CI} ]] || "${CWD}/console" bundle:dump
npm --prefix ${STOREFRONT_ROOT}/Resources/app/storefront clean-install
node ${STOREFRONT_ROOT}/Resources/app/storefront/copy-to-vendor.js
npm --prefix ${STOREFRONT_ROOT}/Resources/app/storefront run production
[[ ${CI} ]] || "${CWD}/console" feature:dump
[[ ${CI} ]] || "${CWD}/console" asset:install
[[ ${CI} ]] || "${CWD}/console" theme:compile