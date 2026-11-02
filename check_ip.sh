#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Error: Provide one IPv4 address" >&2
    exit 1
fi

ip="$1"

# Split the address into four parts.
IFS='.' read -r first second third fourth extra <<< "$ip"

if [ -n "$extra" ] || [[ "$ip" == *. ]]; then
    echo "Error: Provide one IPv4 address" >&2
    exit 1
fi

for part in "$first" "$second" "$third" "$fourth"; do
    # The task requires four groups of digits separated by dots.
    case "$part" in
        ''|*[!0-9]*)
            echo "Error: Provide one IPv4 address" >&2
            exit 1
            ;;
    esac

done

log="exam-data/case/logs/auth.log"
watchlist="exam-data/intel/watchlist.txt"
firewall="exam-data/case/logs/firewall.log"
log_dir="exam-data/case/logs"

if [ ! -r "$log" ] || [ ! -r "$watchlist" ] || [ ! -r "$firewall" ]; then
    echo "Error: Cannot read input files" >&2
    exit 1
fi

# Select lines containing the exact address, including in SRC=IP fields.
# Keep dots inside an address so a longer dotted address cannot match.
ip_lines() {
    awk -v ip="$ip" '{
        original=$0
        gsub(/[^0-9.]/, " ")
        for (i=1; i<=NF; i++) {
            if ($i==ip) {print original; break}
        }
    }' "$1"
}

failed=$(ip_lines "$log" | grep -F "Failed password" | grep -Fwc "$ip" || true)
accepted=$(ip_lines "$log" | grep -F "Accepted password" | grep -Fwc "$ip" || true)

if [ "$failed" -eq 0 ]; then
    risk="NONE"
elif [ "$failed" -le 4 ]; then
    risk="LOW"
elif [ "$failed" -le 9 ]; then
    risk="MEDIUM"
else
    risk="HIGH"
fi

if grep -Fxq "$ip" "$watchlist"; then
    listed="YES"
else
    listed="NO"
fi

echo "IP       : $ip"
echo "Failed   : $failed"
echo "Accepted : $accepted"
echo "Risk     : $risk"
echo "Watchlist: $listed"

firewall_lines=$(ip_lines "$firewall")
if [ -n "$firewall_lines" ]; then
    printf '%s\n' "$firewall_lines"
else
    echo "Firewall: no entries"
fi

if [ "$failed" -gt 0 ] && [ "$accepted" -gt 0 ]; then
    echo "WARNING: successful login after failed attempts."
fi

for logfile in "$log_dir"/*; do
    [ -f "$logfile" ] || continue
    if [ ! -r "$logfile" ]; then
        echo "Error: Cannot read $logfile" >&2
        exit 1
    fi
    matches=$(ip_lines "$logfile")
    if [ -n "$matches" ]; then
        exit 0
    fi
done

exit 3
