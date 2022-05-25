#!/usr/bin/env bash

set -e

if [ "${USER}" == "gitpod" ]; then
    export CURRENT_PROJECT=/workspace/{{ crate_name }}
elif [ "${CODESPACE_NAME}" != "" ]; then
    export CURRENT_PROJECT=/workspaces/{{ crate_name }}
else
    export CURRENT_PROJECT=~/{{ crate_name }}
fi

BUILD_MODE=""
case "$1" in
    ""|"release")
        bash build.sh
        BUILD_MODE="release"
        ;;
    "debug")
        bash build.sh debug
        BUILD_MODE="debug"
        ;;
    *)
        echo "Wrong argument. Only \"debug\"/\"release\" arguments are supported"
        exit 1;;
esac

export ESP_BOARD={{ mcu }}
export ESP_ELF={{ crate_name }}

if [ "${ESP_BOARD}" == "esp32c3" ]; then
    export ESP_ARCH="riscv32imac-unknown-none-elf"
elif [ "${ESP_BOARD}" == "esp32s2" ]; then
    export ESP_ARCH="xtensa-esp32s2-none-elf"
elif [ "${ESP_BOARD}" == "esp32s3" ]; then
    export ESP_ARCH="xtensa-esp32s3-none-elf"
else
    export ESP_ARCH="xtensa-esp32-none-elf"
fi

web-flash --chip ${ESP_BOARD} ${CURRENT_PROJECT}/target/${ESP_ARCH}/${BUILD_MODE}/${ESP_ELF}