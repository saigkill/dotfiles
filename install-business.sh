#!/usr/bin/bash

set -e

CONFIG="linux-business.conf.yml"
CONFIG_ROOT="linux-root.conf.yml"
DOTBOT_DIR="dotbot"

DOTBOT_BIN="bin/dotbot"
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "${BASEDIR}"

read -r -p "Are you have made a backup before? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    "${BASEDIR}/${DOTBOT_DIR}/${DOTBOT_BIN}" -d "${BASEDIR}" -c "${CONFIG}" "${@}"
    sudo "${BASEDIR}/${DOTBOT_DIR}/${DOTBOT_BIN}" -d "${BASEDIR}" -c "${CONFIG_ROOT}" "${@}"
else
    echo "Better made a backup before"
fi

# Ensure that UNIX encoding is used
find . -type f -print0 | grep "bash" | xargs -0 dos2unix

echo "After Installation, please have a look at the output. It can be, that some symlinks are not creted"
echo "If so, please remove the mentioned files and run the script again"
