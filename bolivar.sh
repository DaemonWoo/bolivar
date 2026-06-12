#!/bin/bash

echo "🔍 Bolivar - Disk Summary"
echo "---------------------------"

# to_gb() {
# 	awk -v bytes="$1" 'BEGIN { printf "%.2f GB", bytes / 1000 / 1000 / 1000 }'
# }

INFO=$(diskutil apfs list)

TOTAL_BYTES=$(echo "$INFO" | awk -F': *' '
/Capacity Ceiling/ {print $2}' | sed 's/ (.*//')
USED_BYTES=$(echo "$INFO" | awk -F': *' '
/Capacity In Use By Volumes/ {print $2}' | sed 's/ (.*//')
FREE_BYTES=$(echo "$INFO" | awk -F': *' '
/Capacity Not Allocated/ {print $2}' | sed 's/ (.*//')
USED_GB=$(echo "$INFO" | awk -F'[()]' '
/Capacity In Use By Volumes/ {print $2}')
FREE_GB=$(echo "$INFO" | awk -F'[()]' '/Capacity Not Allocated/ {print $2}')
TOTAL_GB=$(echo "$INFO" | awk -F': *' '/Capacity Ceiling/ {print $2; exit}' | sed 's/^.*(//; s/)$//')
USAGE_PCT=$(echo '%s\n' "$INFO" | grep 'Capacity In Use By Volumes' | grep -oE '[0-9.]+% used' | awk '{print $1}')
FREE_PCT=$(echo '%s\n' "$INFO" | grep 'Capacity Not Allocated' | grep -oE '[0-9.]+% free' | awk '{print $1}')

echo "(APFS Container)"
echo "Total: $TOTAL_GB ($TOTAL_BYTES)"
echo "Used: $USED_GB ($USED_BYTES) $USAGE_PCT"
echo "Free: $FREE_GB ($FREE_BYTES) $FREE_PCT"
