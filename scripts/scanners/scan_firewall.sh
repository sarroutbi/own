#!/bin/bash
#
# Copyright (c) 2026, Sergio Arroutbi Braojos <sarroutb (at) redhat.com>
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#
# Script to temporarily open firewall ports for network scanner discovery
# (mDNS + IPP on port 631) so simple-scan can detect the device.

# Check for root privileges
if [[ $(id -u) -ne 0 ]]; then
    echo "ERROR: This script must be run as root (or via sudo)."
    exit 1
fi

# Parse flags (all disabled by default)
RESTORE=0
FORCE_POST_ENABLE=0
for arg in "$@"; do
    if [[ "${arg}" == "--restore" ]]; then
        RESTORE=1
    elif [[ "${arg}" == "--force-post-enable" ]]; then
        FORCE_POST_ENABLE=1
    fi
done

# Save original SELinux mode and set permissive if enforcing
SELINUX_WAS_ENFORCING=0
if command -v getenforce &>/dev/null; then
    SELINUX_MODE=$(getenforce)
    if [[ "${SELINUX_MODE}" == "Enforcing" ]]; then
        echo "SELinux is Enforcing. Setting to Permissive temporarily."
        setenforce 0
        SELINUX_WAS_ENFORCING=1
    else
        echo "SELinux is ${SELINUX_MODE}. No change needed."
    fi
fi

# Add firewall rules: mDNS service + IPP ports (runtime only, no --permanent)
add_rules() {
    firewall-cmd --add-service=mdns
    firewall-cmd --add-port=631/tcp
    firewall-cmd --add-port=631/udp
}

# Remove the rules we just added
remove_rules() {
    firewall-cmd --remove-service=mdns
    firewall-cmd --remove-port=631/tcp
    firewall-cmd --remove-port=631/udp
}

# Make rules permanent so they survive firewall reloads/reboots
force_enable_rules() {
    firewall-cmd --permanent --add-service=mdns
    firewall-cmd --permanent --add-port=631/tcp
    firewall-cmd --permanent --add-port=631/udp
}

# Apply rules
add_rules
echo "Firewall rules applied: mDNS service, 631/tcp, 631/udp."

# If --force-post-enable was passed, make rules permanent
if [[ ${FORCE_POST_ENABLE} -eq 1 ]]; then
    force_enable_rules
    echo "Firewall rules made permanent."
fi

# If --restore was passed, wait for user then clean up
if [[ ${RESTORE} -eq 1 ]]; then
    echo 'Please, scan now. Firewall configuration will be restored after you press "C/c" (continue).'
    # Loop until the user types exactly 'C' or 'c'
    while true; do
        read -r -n 1 key
        if [[ "${key}" == "C" || "${key}" == "c" ]]; then
            echo ""
            remove_rules
            echo "Firewall rules removed. Configuration restored."
            if [[ ${SELINUX_WAS_ENFORCING} -eq 1 ]]; then
                setenforce 1
                echo "SELinux restored to Enforcing."
            fi
            break
        fi
    done
fi
