#!/bin/bash
SPLIT="---------------------------"
echo "🔍 Bolivar - Disk Summary"
echo $SPLIT

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

START=$(date +%s)
echo $SPLIT

MAX_JOBS=$(( $(sysctl -n hw.logicalcpu) / 2 ))
TMP=$(mktemp)

while IFS= read -r dir; do
    (du -sk "$dir" 2>/dev/null >> "$TMP") &

    while [ "$(jobs -p | wc -l | tr -d ' ')" -ge "$MAX_JOBS" ]; do
        sleep 0.1
    done

done < <(
    find "$HOME" -mindepth 1 -maxdepth 1 -type d
)

wait

sort -nr "$TMP" |
awk '{printf "%.2f GB\t%s\n", $1/1024/1024, $2}' | head -10

rm "$TMP"

echo $SPLIT
END=$(date +%s)
echo "Scan completed in $((END - START)) seconds."

# echo $SPLIT
# echo "Scanning home directory..."
# echo $SPLIT
# LARGEST_FILEs=$(find "$HOME" -type f -exec stat -f "%z %N" {} \; 2>/dev/null |
# sort -nr |
# head -20)

# echo "Top-10 largest files:"
# echo "$LARGEST_FILEs"