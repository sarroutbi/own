#!/bin/bash
#
# Copyright (c) 2025 Red Hat, Inc.
#
# Author: Sergio Arroutbi <sarroutb@redhat.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
DEFAULT_VERSION="1.39.1"

function usage() {
  echo "$1 [-v version]"
  echo ""
  exit "$2"
}

while getopts "v:h" arg
do
  case "${arg}" in
    v) VERSION=${OPTARG}
       ;;
    h) usage "$0" 0
       ;;
    *) usage "$0" 1
       ;;
  esac
done

test -z "${VERSION}" && VERSION="${DEFAULT_VERSION}"
echo "Downloading VERSION:${VERSION}"

ARCH=$(case $(uname -m) in x86_64) echo -n amd64 ;; aarch64) echo -n arm64 ;; *) echo -n "$(uname -m)" ;; esac)
export ARCH
OS=$(uname | awk '{print tolower($0)}')
export OS
export OPERATOR_SDK_DL_URL="https://github.com/operator-framework/operator-sdk/releases/download/v${VERSION}"
curl -LO "${OPERATOR_SDK_DL_URL}/operator-sdk_${OS}_${ARCH}"
gpg --keyserver keyserver.ubuntu.com --recv-keys 052996E2A20B5C7E
curl -LO "${OPERATOR_SDK_DL_URL}/checksums.txt"
curl -LO "${OPERATOR_SDK_DL_URL}/checksums.txt.asc"
gpg -u "Operator SDK (release) <cncf-operator-sdk@cncf.io>" --verify checksums.txt.asc
grep "operator-sdk_${OS}_${ARCH}" checksums.txt | sha256sum -c -
chmod +x "operator-sdk_${OS}_${ARCH}" && sudo mv "operator-sdk_${OS}_${ARCH}" /usr/local/bin/operator-sdk
