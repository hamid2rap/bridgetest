#!/data/data/com.termux/files/usr/bin/bash

# Colors
GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"
BORDER="===================================================="

# Source file
RAW_URL="https://raw.githubusercontent.com/scriptzteam/Tor-Bridges-Collector/main/bridges-obfs4"

echo "Fetching bridges..."
bridges=$(curl -s "$RAW_URL" | grep -v '^#' | grep -v '^$')

echo "Starting fast parallel test..."

# Function to test one bridge
test_bridge() {
    line="$1"
    hostport=$(echo "$line" | awk '{print $2}')
    host=$(echo "$hostport" | cut -d: -f1)
    port=$(echo "$hostport" | cut -d: -f2)

    if timeout 3 nc -z "$host" "$port" >/dev/null 2>&1; then
        echo -e "$BORDER\nHAMID TEST BRIDGE\n${GREEN}OK ✅${RESET}\n$line\n$BORDER"
    else
        echo -e "$BORDER\nHAMID TEST BRIDGE\n${RED}FAILED ❌${RESET}\n$line\n$BORDER"
    fi
}

export -f test_bridge
export GREEN RED RESET BORDER

# Run tests in parallel but keep output ordered
echo "$bridges" | xargs -I{} -n1 -P20 bash -c 'test_bridge "$@"' _ {}
