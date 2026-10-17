
#!/bin/bash

TOTAL_MATCHES=0

while IFS= read -r -d '' LOGFILE; do

    MATCHES=0
    LINES=$(wc -l < "$LOGFILE")
    FAILED=$(grep -c "Failed password" "$LOGFILE")

    while IFS= read -r INDICATOR; do

        [ -z "$INDICATOR" ] && continue

        if grep -qwF "$INDICATOR" "$LOGFILE"; then
            MATCHES=$((MATCHES + 1))
            TOTAL_MATCHES=$((TOTAL_MATCHES + 1))
        fi

        if [ "$MATCHES" -eq 3 ]; then
            echo "Stopped checking $LOGFILE early: 3 IOC matches found."
            break
        fi

    done < intel/iocs.txt

    echo "File: $LOGFILE"
    echo "Total lines: $LINES"
    echo "Failed logins: $FAILED"
    echo "IOC matches: $MATCHES"
    echo "------------------------"

done < <(find case -type f -name "*.log" -print0)

echo "Total IOC matches across all logs: $TOTAL_MATCHES"

if [ "$TOTAL_MATCHES" -eq 0 ]; then
    exit 0
else
    exit 1
fi

