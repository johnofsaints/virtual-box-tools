#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)

usage()
{
    echo "Usage: ${0} MACHINE_NAME MEMORY"
}

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}"/../lib/virtual_box_tools.sh
MACHINE_NAME="${1}"
MEMORY="${2}"

if [ "${MACHINE_NAME}" = "" ] || [ "${MEMORY}" = "" ]; then
    usage

    exit 1
fi

${VBOXMANAGE} modifyvm "${MACHINE_NAME}" --memory "${MEMORY}"
