#!/bin/bash

[[ "$(whoami)" != 'root' ]] && { echo "Run as root. Use sudo"; exit 1; }

SWAP_NAME="swap"
SWAP_PATH="/${SWAP_NAME}"

get_available_ram_mb() {
    awk '/MemAvailable/ { print int($2/1024) }' /proc/meminfo
}

get_debian_version() {
    if [[ -f /etc/debian_version ]]; then
        cut -d. -f1 /etc/debian_version
    else
        echo 0
    fi
}

get_swappiness_value_no_stde() {
    local ver
    ver=$(get_debian_version)
    if (( ver >= 12 )); then
        echo "Debian ${ver} detected: setting swappiness=180 (zswap/zram optimized)"
        echo 180
    else
        echo "Debian ${ver} (or non-Debian) detected: setting swappiness=88"
        echo 88
    fi
}
get_swappiness_value() {
    local ver
    ver=$(get_debian_version)
    if (( ver >= 12 )); then
        echo "Debian ${ver} detected: swappiness=180 (zswap/zram optimized)" >&2
        echo 180
    else
        echo "Debian ${ver} (or non-Debian) detected: swappiness=88" >&2
        echo 88
    fi
}

get_swap_size_mb() {
    local size
    while true; do
        echo "Enter swap size in GB (integer only):" >&2
        read -r size
        if [[ "$size" =~ ^[1-9][0-9]*$ ]]; then
            echo $(( size * 1024 ))
            return 0
        fi
        echo "Invalid input. Enter a positive integer." >&2
    done
}

apply_sysctl() {
    local key=$1 val=$2
    if grep -q "^${key}" /etc/sysctl.conf; then
        echo "${key} already set: $(grep "^${key}" /etc/sysctl.conf)"
        echo "Modify manually if needed."
    else
        echo "${key} = ${val}" >> /etc/sysctl.conf
        sysctl -w "${key}=${val}" > /dev/null
        echo "Applied: ${key} = ${val}"
    fi
}

make_swap() {
    local size_mb=$1
    local ram_mb
    ram_mb=$(get_available_ram_mb)

    echo "Available RAM: ${ram_mb}MB | Requested swap: ${size_mb}MB"
    (( size_mb > ram_mb )) && echo "WARNING: Swap size > available RAM. Using bs=1M to avoid OOM..."

    echo "Creating ${SWAP_PATH} (${size_mb}MB)..."
    dd if=/dev/zero of="${SWAP_PATH}" bs=1M count="${size_mb}" status=progress iflag=fullblock
    [[ $? -ne 0 ]] && { echo "dd failed. Check disk space."; exit 1; }

    chmod 600 "${SWAP_PATH}"
    mkswap "${SWAP_PATH}"
    swapon "${SWAP_PATH}"

    echo "--- Swap status ---"
    swapon -s

    if grep -q '\sswap\s' /etc/fstab; then
        echo "/etc/fstab: swap entry exists, skipping."
    else
        echo "${SWAP_PATH}   none    swap    sw    0   0" >> /etc/fstab
        echo "Added swap to /etc/fstab"
    fi

    local swappiness
    swappiness=$(get_swappiness_value)

    apply_sysctl "vm.swappiness" "$swappiness"
    apply_sysctl "vm.vfs_cache_pressure" 50

    echo "Swap setup complete!"
}

size_mb=$(get_swap_size_mb)
make_swap "$size_mb"
