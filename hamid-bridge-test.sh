#!/data/data/com.termux/files/usr/bin/bash

# Colors
GREEN="\033[0;32m"
RED="\033[0;31m"
CYAN="\033[0;36m"
RESET="\033[0m"
BORDER="===================================================="

RAW_URL="https://raw.githubusercontent.com/scriptzteam/Tor-Bridges-Collector/main/bridges-obfs4"

echo -e "${CYAN}Fetching bridges...${RESET}"
bridges=$(curl -s "$RAW_URL" | grep -v '^#' | grep -v '^$' | head -n 200)

total=$(echo "$bridges" | wc -l)
count=0

# Temp file to store results
tmpfile=$(mktemp)

echo -e "${CYAN}Testing $total bridges...${RESET}"

while read -r line; do
    count=$((count+1))
    hostport=$(echo "$line" | awk '{print $2}')
    host=$(echo "$hostport" | cut -d: -f1)
    port=$(echo "$hostport" | cut -d: -f2)

    (
      start=$(date +%s%3N)
      if timeout 3 nc -z "$host" "$port" >/dev/null 2>&1; then
          end=$(date +%s%3N)
          ping=$((end-start))
          echo "$ping|$line" >> "$tmpfile"
      fi
    ) &

    # Progress percentage
    progress=$((count*100/total))
    echo -ne "Progress: $progress% ($count/$total)\r"
done <<< "$bridges"

wait
echo -e "\n${CYAN}Testing complete.${RESET}"

# Sort by ping and pick top 3
echo -e "${CYAN}Top 3 fastest bridges:${RESET}"
sort -n "$tmpfile" | head -n 3 | while IFS="|" read ping line; do
    echo -e "$BORDER"
    echo -e "HAMID TEST BRIDGE"
    echo -e "${GREEN}OK ✅ Ping: ${ping} ms${RESET}"
    echo -e "$line"
    echo -e "$BORDER"
done

rm "$tmpfile"
