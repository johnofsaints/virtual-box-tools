#!/bin/sh -e

SCRIPT_DIR=$(cd "$(dirname "${0}")"; pwd)

usage(){
    echo "Usage: ${0} [--verbose] VM_NAME"
}

if [ "${1}" = "--verbose" ]; then
    set -x
    shift
fi

if [ "${1}" = "" ]; then
    usage

    exit 1
fi

NAME="${1}"
NOT_FOUND=false
"${SCRIPT_DIR}/show-info.sh" "${NAME}" > /dev/null 2>&1 || NOT_FOUND=true

if [ "${NOT_FOUND}" = true ]; then
    echo "Not found: ${NAME}"

    exit 1
else
    IS_RUNNING=$("${SCRIPT_DIR}/list-vms.sh" | grep "${NAME}")

    if [ ! "${IS_RUNNING}" = "" ]; then
        echo "Stop vm."
        "${SCRIPT_DIR}/stop-vm.sh" "${NAME}"
        DOWN=false

        for SECOND in $(seq 1 30); do
            echo "${SECOND}"
            sleep 1
            STATE=$(vboxmanage showvminfo --machinereadable "${NAME}" | grep "VMState=")
            STATE=${STATE#*=}
            STATE=$(echo "${STATE}" | sed 's/"//g')

            if [ "${STATE}" = "poweroff" ]; then
                DOWN=true

                break
            fi
        done

        if [ "${DOWN}" = "false" ]; then
            echo "Force shutdown."
            "${SCRIPT_DIR}/stop-vm.sh" --force "${NAME}"
            sleep 3
        fi
    fi
fi

vboxmanage unregistervm "${NAME}" --delete
