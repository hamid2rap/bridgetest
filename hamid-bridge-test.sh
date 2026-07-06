#!/data/data/com.termux/files/usr/bin/bash

# Colors
GREEN="\033[1;32m"
RESET="\033[0m"

RAW_URL="https://raw.githubusercontent.com/scriptzteam/Tor-Bridges-Collector/main/bridges-obfs4"

echo "Fetching bridges..."
bridges=$(curl -s "$RAW_URL" | grep -v '^#' | grep -v '^$' | head -n 200)

total=$(echo "$bridges" | wc -l)
count=0
tmpfile=$(mktemp)

echo "Testing $total bridges..."

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

    progress=$((count*100/total))
    echo -ne "Progress: $progress% ($count/$total)\r"
done <<< "$bridges"

wait
echo -e "\nTesting complete."

# Big green banner
echo -e "${GREEN}"
echo "################################################################################################"
echo "#                                                                                              #"
echo "#                                   HAMID TEST BRIDGE                                          #"
echo "#                                                                                              #"
echo "################################################################################################"
echo -e "${RESET}"

# Show top 3 fastest bridges
sort -n "$tmpfile" | head -n 3 | while IFS="|" read ping line; do
    echo -e "${GREEN}Bridge: $line${RESET}"
    echo -e "${GREEN}Ping: ${ping} ms${RESET}"
    echo -e "${GREEN}--------------------------------------------------------------------------------------------${RESET}"
done

rm "$tmpfile"
