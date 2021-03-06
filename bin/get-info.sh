#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)

usage()
{
    echo "Usage: ${0} MACHINE_NAME"
}

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}"/../lib/virtual_box_tools.sh
MACHINE_NAME="${1}"

if [ "${MACHINE_NAME}" = "" ]; then
    usage

    exit 1
fi

ERROR=false
OUTPUT=$(${VBOXMANAGE} showvminfo "${MACHINE_NAME}" 2>&1) || ERROR=true

if [ "${ERROR}" = false ]; then
    echo "${OUTPUT}"
else
    echo "Error:"
    echo "${OUTPUT}"

    exit 1
fi
