#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <logfile>" >&2
    exit 1
fi

LOGFILE="$1"

if [ ! -f "$LOGFILE" ]; then
    echo "Error: file '$LOGFILE' not found" >&2
    exit 2
fi

FAILED=$(grep -c "Failed password" "$LOGFILE")

echo "Total failed password events: $FAILED"

if [ "$FAILED" -eq 0 ]; then
    echo "Top failed-login IP: None"
    echo "Top 3 source IPs: None"
    echo "Top 3 targeted usernames: None"
    exit 0
fi

TOP_IP=$(grep "Failed password" "$LOGFILE" | awk '{for(i=1;i<=NF;i++) if($i=="from") print $(i+1)}' | sort | uniq -c | sort -rn | awk '{print $2}')

echo "Top failed-login IP: $TOP_IP"

echo "Top 3 source IPs:"
./top3.sh "$LOGFILE"

echo "Top 3 targeted usernames:"
grep "Failed password" "$LOGFILE" | awk '{for(i=1;i<=NF;i++) if($i=="for") {if($(i+1)=="invalid") print $(i+3); else print $(i+1)}}' | sort | uniq -c | sort -rn | head -n 3

exit 0
