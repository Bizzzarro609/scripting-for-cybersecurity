#!/bin/bash

csv="exam-data/intel/users.csv"
log="exam-data/case/logs/auth.log"

if [ ! -r "$csv" ] || [ ! -r "$log" ]; then
    echo "Error: Cannot read CSV or auth.log" >&2
    exit 1
fi

active=0
disabled=0

{
    IFS= read -r header

    while IFS=',' read -r username role status department || [ -n "$username" ]; do
        [ -z "$username" ] && continue
        department=$(printf '%s' "$department" | tr -d '\r')

        logins=$(grep -F "Accepted password for $username from " "$log" | wc -l)

        printf '%s | %s | %s | %s | logins: %s\n' \
            "$username" "$role" "$status" "$department" "$logins"

        if [ "$status" = "active" ]; then
            active=$((active + 1))
        elif [ "$status" = "disabled" ]; then
            disabled=$((disabled + 1))
            if [ "$logins" -gt 0 ]; then
                echo "ALERT: Disabled account $username has successful logins"
            fi
        fi
    done
} < "$csv"

echo "Active accounts: $active"
echo "Disabled accounts: $disabled"
exit 0
