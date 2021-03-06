#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)

usage()
{
    echo "Usage: ${0} [--force][--wait] MACHINE_NAME"
}

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}"/../lib/virtual_box_tools.sh
FORCE=false
WAIT=false

while true; do
    case ${1} in
        --force)
            FORCE=true
            shift
            ;;
        --wait)
            WAIT=true
            shift
            ;;
        *)
            break
            ;;
    esac
done

MACHINE_NAME="${1}"

if [ "${MACHINE_NAME}" = "" ]; then
    usage

    exit 1
fi

if [ "${FORCE}" = true ]; then
    echo "Force shutdown."
    ${VBOXMANAGE} controlvm "${MACHINE_NAME}" poweroff
else
    echo "Stop running virtual machine '${MACHINE_NAME}'."
    ${VBOXMANAGE} controlvm "${MACHINE_NAME}" acpipowerbutton
fi

if [ "${WAIT}" = true ]; then
    for SECOND in $(seq 1 30); do
        echo "${SECOND}"
        sleep 1
        STATE=$("${SCRIPT_DIRECTORY}"/get-vm-state.sh "${MACHINE_NAME}")

        if [ "${STATE}" = poweroff ]; then
            DOWN=true

            break
        fi
    done

    if [ "${DOWN}" = false ]; then
        echo "Error: Virtual machine could not be stopped."
    fi
fi
