#!/usr/bin/bash
# PKCS#11 YubiKey setup and diagnostic script for VM environments
# Usage: sudo ./test-pkcs11-setup.sh [pin] [module-path]

PIN="${1:-123456}"
MODULE="${2:-/usr/lib64/libykcs11.so.2}"
VENDOR="1050"
PRODUCT="0405"
FAIL=0
MAX_RETRIES=5

step() {
    echo "== [$1] $2"
}

fail() {
    echo "   FAIL: $1"
    FAIL=1
}

ok() {
    echo "   OK: $1"
}

indent() {
    while IFS= read -r line; do
        echo "   $line"
    done
}

kill_all_pcscd() {
    systemctl stop pcscd.service pcscd.socket 2>/dev/null
    while pgrep pcscd > /dev/null 2>&1; do
        kill -9 "$(pgrep pcscd)" 2>/dev/null
        sleep 1
    done
    rm -f /run/pcscd/pcscd.pid
}

# Step 1: Check YubiKey visible via lsusb
step 1 "Checking YubiKey USB presence"
if ! lsusb | grep -qi yubi; then
    fail "YubiKey not found in lsusb output"
    echo "   Ensure the YubiKey is attached as a USB Host Device (not SPICE redirect)"
    exit 1
fi
ok "$(lsusb | grep -i yubi)"

# Step 2: Check CCID interface exists
step 2 "Checking CCID interface (class 0b)"
YKDEV=""
for d in /sys/bus/usb/devices/*; do
    [ -f "$d/idVendor" ] || continue
    [ "$(cat "$d/idVendor")" = "$VENDOR" ] && [ "$(cat "$d/idProduct")" = "$PRODUCT" ] && YKDEV="$d" && break
done
if [ -z "$YKDEV" ]; then
    fail "YubiKey sysfs device not found"
    exit 1
fi
CCID_FOUND=0
for iface in "$YKDEV":*; do
    class=$(cat "$iface/bInterfaceClass" 2>/dev/null)
    driver=$(basename "$(readlink "$iface/driver" 2>/dev/null)" 2>/dev/null || echo "none")
    echo "   Interface $(basename "$iface"): class=$class driver=$driver"
    [ "$class" = "0b" ] && CCID_FOUND=1
done
if [ "$CCID_FOUND" -eq 0 ]; then
    fail "No CCID interface found. Attempting USB rebind..."
    devname=$(basename "$YKDEV")
    echo "$devname" > /sys/bus/usb/drivers/usb/unbind 2>/dev/null
    sleep 2
    echo "$devname" > /sys/bus/usb/drivers/usb/bind 2>/dev/null
    sleep 1
    CCID_FOUND=0
    for iface in "$YKDEV":*; do
        class=$(cat "$iface/bInterfaceClass" 2>/dev/null)
        [ "$class" = "0b" ] && CCID_FOUND=1
    done
    if [ "$CCID_FOUND" -eq 0 ]; then
        fail "CCID interface still missing after rebind"
        exit 1
    fi
    ok "CCID interface restored after rebind"
fi

# Step 3: Kill stale pcscd and clean up
step 3 "Cleaning up stale pcscd"
kill_all_pcscd
ok "All pcscd processes killed, PID file cleaned"

# Step 4: Start pcscd fresh and verify it can claim the device
step 4 "Starting pcscd (with retry)"
ATTEMPT=0
PCSCD_OK=0
while [ "$ATTEMPT" -lt "$MAX_RETRIES" ]; do
    ATTEMPT=$((ATTEMPT + 1))
    kill_all_pcscd
    sleep 1
    systemctl start pcscd.socket
    sleep 2
    SLOTS=$(pkcs11-tool -L --module "$MODULE" 2>&1)
    if echo "$SLOTS" | grep -qi "yubi\|slot 0"; then
        PCSCD_OK=1
        break
    fi
    echo "   Attempt $ATTEMPT/$MAX_RETRIES: pcscd can't claim device, retrying..."
done
if [ "$PCSCD_OK" -eq 0 ]; then
    fail "pcscd failed to claim device after $MAX_RETRIES attempts"
    journalctl -u pcscd.service --since "60 sec ago" --no-pager 2>/dev/null | indent
    exit 1
fi
ok "pcscd started and claimed device (attempt $ATTEMPT)"

# Step 5: Check pkcs11-tool -L
step 5 "Checking pkcs11-tool -L (default module)"
SLOTS=$(pkcs11-tool -L 2>&1)
if echo "$SLOTS" | grep -qi "yubi\|slot"; then
    ok "Default module sees slots"
    echo "$SLOTS" | head -10 | indent
else
    echo "   WARN: Default module shows no slots (may need --module)"
fi

# Step 6: Check pkcs11-tool -L with YubiKey module
step 6 "Checking pkcs11-tool -L --module $MODULE"
if [ ! -f "$MODULE" ]; then
    fail "Module not found: $MODULE"
    exit 1
fi
SLOTS=$(pkcs11-tool -L --module "$MODULE" 2>&1)
if echo "$SLOTS" | grep -qi "yubi\|slot 0"; then
    ok "YubiKey module sees slots"
    echo "$SLOTS" | head -10 | indent
else
    fail "YubiKey module shows no slots"
    echo "$SLOTS" | indent
    journalctl -u pcscd.service --since "30 sec ago" --no-pager 2>/dev/null | indent
    exit 1
fi

# Step 7: Check objects on the token
step 7 "Checking objects on token"
OBJECTS=$(pkcs11-tool -O --module "$MODULE" 2>&1)
if echo "$OBJECTS" | grep -qi "public key"; then
    ok "Public key found"
    echo "$OBJECTS" | grep -E "label:|ID:|type" | head -6 | indent
else
    fail "No public key found. Generating key pair..."
    if ! command -v yubico-piv-tool > /dev/null 2>&1; then
        fail "yubico-piv-tool not installed, cannot generate keys"
        exit 1
    fi
    yubico-piv-tool -a generate -s 9d -A RSA2048 -o /tmp/public.pem 2>&1 | indent
    yubico-piv-tool -a verify-pin -P "$PIN" -a selfsign-certificate -s 9d -S '/CN=clevis/' -i /tmp/public.pem -o /tmp/cert.pem 2>&1 | indent
    yubico-piv-tool -a import-certificate -s 9d -i /tmp/cert.pem 2>&1 | indent
    OBJECTS=$(pkcs11-tool -O --module "$MODULE" 2>&1)
    if echo "$OBJECTS" | grep -qi "public key"; then
        ok "Key pair generated and certificate imported"
    else
        fail "Key generation failed"
        echo "$OBJECTS" | indent
        exit 1
    fi
fi

# Step 8: Test clevis encrypt/decrypt
step 8 "Testing clevis encrypt/decrypt"
RESULT=$(echo "clevis-pkcs11-test" | clevis encrypt pkcs11 "{\"uri\":\"pkcs11:module-path=${MODULE}?pin-value=${PIN}\"}" 2>/dev/null | clevis decrypt 2>/dev/null)
if [ "$RESULT" = "clevis-pkcs11-test" ]; then
    ok "clevis encrypt/decrypt successful"
else
    fail "clevis encrypt/decrypt failed (got: '$RESULT')"
    echo "   Testing encrypt only..."
    echo "clevis-pkcs11-test" | clevis encrypt pkcs11 "{\"uri\":\"pkcs11:module-path=${MODULE}?pin-value=${PIN}\"}" 2>&1 | indent
    exit 1
fi

# Summary
echo ""
if [ "$FAIL" -eq 0 ]; then
    echo "All checks passed. PKCS#11 YubiKey is ready for use."
else
    echo "Some checks failed. Review output above."
fi
