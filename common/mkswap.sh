#!/bin/bash

[[ "$(whoami)" != 'root' ]] && { echo "Run as root. Use sudo"; exit 1; }

SWAP_NAME="swap"
SWAP_PATH="/${SWAP_NAME}"

get_available_ram_mb() {
    awk '/MemAvailable/ { print int($2/1024) }' /proc/meminfo
}

get_debian_version() {
    [[ -f /etc/debian_version ]] && cut -d. -f1 /etc/debian_version || echo 0
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

# Find the sysctl target file for a given key.
# Debian >= 13: search /etc/sysctl.d/*.conf for existing (non-commented) entry.
# Falls back to creating /etc/sysctl.d/00.swap.conf if not found.
# Debian < 13: use /etc/sysctl.conf
get_sysctl_target() {
    local key=$1
    local ver
    ver=$(get_debian_version)

    if (( ver >= 13 )); then
        local found
        found=$(grep -rl "^${key}" /etc/sysctl.d/*.conf 2>/dev/null | head -1)
        if [[ -n "$found" ]]; then
            echo "$found"
        else
            echo "/etc/sysctl.d/00.swap.conf"
        fi
    else
        echo "/etc/sysctl.conf"
    fi
}

apply_sysctl() {
    local key=$1 val=$2
    local target
    target=$(get_sysctl_target "$key")

    if [[ -f "$target" ]] && grep -q "^${key}" "$target"; then
        echo "${key} already set in ${target}: $(grep "^${key}" "$target")"
        echo "Modify manually if needed."
    else
        echo "${key} = ${val}" >> "$target"
        sysctl -w "${key}=${val}" > /dev/null
        echo "Applied: ${key} = ${val} -> ${target}"
    fi
}

add_fstab_entry() {
    # Match only lines where the first field (device/path) is exactly SWAP_PATH
    if awk '$1 == "'"${SWAP_PATH}"'" { found=1 } END { exit !found }' /etc/fstab; then
        echo "/etc/fstab: ${SWAP_PATH} entry exists, skipping."
    else
        echo "${SWAP_PATH}   none    swap    sw    0   0" >> /etc/fstab
        echo "Added ${SWAP_PATH} to /etc/fstab"
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

    add_fstab_entry

    local swappiness
    swappiness=$(get_swappiness_value)
    apply_sysctl "vm.swappiness" "$swappiness"
    apply_sysctl "vm.vfs_cache_pressure" 50

    echo "Swap setup complete!"
}

size_mb=$(get_swap_size_mb)
make_swap "$size_mb"
