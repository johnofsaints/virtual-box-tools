#!/bin/sh -e

function_exists()
{
    declare -f -F "${1}" > /dev/null

    return $?
}

CONFIG="${HOME}/.virtual-box-tools.yaml"

while true; do
    case ${1} in
        --help)
            echo "Global usage: ${0} [--help][--config CONFIG]"

            if function_exists usage; then
                usage
            fi

            exit 0
            ;;
        --config)
            CONFIG=${2-}
            shift 2
            ;;
        *)
            break
            ;;
    esac
done

OPTIND=1
CONFIG=$(realpath "${CONFIG}")

if [ -f "${CONFIG}" ]; then
    DIRECTORY=$(dirname "${0}")
    SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)
    SHYAML="${SCRIPT_DIRECTORY}/../.venv/bin/shyaml"
    SUDO_USER=$(${SHYAML} get-value sudo_user < "${CONFIG}" 2> /dev/null || true)
else
    CONFIG=""
fi

if [ "${SUDO_USER}" = "" ]; then
    VBOXMANAGE=vboxmanage
else
    SUDO="sudo -u ${SUDO_USER}"
    VBOXMANAGE="${SUDO} vboxmanage"
    export SUDO
fi

export VBOXMANAGE
