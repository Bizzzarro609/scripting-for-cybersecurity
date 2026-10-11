#!/bin/bash

read -p "Enter the username: " TARGET_USER

if [ -z "$TARGET_USER" ]; then
    echo "Username is empty" >&2
    exit 1
fi

USERNAME="$TARGET_USER"

if grep -q "^$USERNAME," intel/users.csv; then
    SOURCE="CURRENT"

    ROLE=$(awk -F',' -v user="$USERNAME" '$1 == user {print $2}' intel/users.csv)
    STATUS=$(awk -F',' -v user="$USERNAME" '$1 == user {print $3}' intel/users.csv)

    echo "$USERNAME: CURRENT account"
    echo "Role: $ROLE"
    echo "Status: $STATUS"

elif grep -qx "$USERNAME" case/backups/users.old; then
    SOURCE="LEGACY"
    echo "$USERNAME: LEGACY account"
else
    SOURCE="UNKNOWN"
    echo "$USERNAME: UNKNOWN account"
fi

LOG="case/logs/auth.log"

FAILED=$(grep -Fc "Failed password for $USERNAME " "$LOG")
ACCEPTED=$(grep -Fc "Accepted password for $USERNAME " "$LOG")

echo "Failed logins: $FAILED"
echo "Accepted logins: $ACCEPTED"

COUNT="$FAILED"

if [ "$COUNT" -eq 0 ]; then
    echo "Risk: NONE"
elif [ "$COUNT" -lt 5 ]; then
    echo "Risk: LOW"
elif [ "$COUNT" -lt 15 ]; then
    echo "Risk: MEDIUM"
else
    echo "Risk: HIGH"
fi

if [ "$SOURCE" = "CURRENT" ] && [ "$STATUS" = "disabled" ] && [ "$ACCEPTED" -gt 0 ]; then
    echo "WARNING: Disabled account has accepted logins!"
fi

if [ "$SOURCE" = "LEGACY" ] || [ "$SOURCE" = "UNKNOWN" ]; then
    if [ "$FAILED" -gt 0 ]; then
        echo "WARNING: Attacker is guessing legacy or unknown usernames!"
    fi
fi

if [ "$SOURCE" = "CURRENT" ] && [ "$ACCEPTED" -gt 0 ]; then
    if grep -q "^$USERNAME:" case/evidence/passwords.txt; then
        echo "WARNING: Plaintext credentials found with successful logins!"
    fi
fi

if [ "$SOURCE" = "CURRENT" ]; then
    exit 0
elif [ "$SOURCE" = "LEGACY" ]; then
    exit 2
else
    exit 3
fi
