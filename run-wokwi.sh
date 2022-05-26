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

if [ "${USER}" == "gitpod" ];then
    gp_url=$(gp url 9012)
    echo "gp_url=${gp_url}"
    export WOKWI_HOST=${gp_url:8}
elif [ "${CODESPACE_NAME}" != "" ];then
    export WOKWI_HOST=${CODESPACE_NAME}-9012.githubpreview.dev
fi

{%- if mcu == "esp32c3" -%}
export ESP_ARCH=riscv32imac-unknown-none-elf
{%- else -%}
export ESP_ARCH=xtensa-{{ mcu }}-none-elf
{%- endif %}

# TODO: Update with your Wokwi Project
export WOKWI_PROJECT_ID=""
if [ "${WOKWI_PROJECT_ID}" == "" ]; then
    wokwi-server --chip {{ mcu }} ${CURRENT_PROJECT}/target/${ESP_ARCH}/${BUILD_MODE}/{{ crate_name }}
else
    wokwi-server --chip {{ mcu }} --id ${WOKWI_PROJECT_ID} ${CURRENT_PROJECT}/target/${ESP_ARCH}/${BUILD_MODE}/{{ crate_name }}
fi