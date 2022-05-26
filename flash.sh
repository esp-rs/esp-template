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

{%- if mcu == "esp32c3" -%}
export ESP_ARCH=riscv32imac-unknown-none-elf
{%- else -%}
export ESP_ARCH=xtensa-{{ mcu }}-none-elf
{%- endif %}

web-flash --chip {{ mcu }} ${CURRENT_PROJECT}/target/${ESP_ARCH}/${BUILD_MODE}/{{ crate_name }}
