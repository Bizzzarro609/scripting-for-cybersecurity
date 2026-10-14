#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 <logfile> <username>" >&2
    exit 1
fi

LOGFILE=$1
TERM_ARG=$2

if [ ! -e "$LOGFILE" ]; then
    echo "Error: File does not exist" >&2
    exit 2
fi

if [ ! -f "$LOGFILE" ]; then
    echo "Error: Not a regular file" >&2
    exit 3
fi

if [ ! -r "$LOGFILE" ]; then
    echo "Error: File is not readable" >&2
    exit 4
fi

if [ -z "$TERM_ARG" ]; then
    echo "Error: Search term is empty" >&2
    exit 5
fi

if echo "$TERM_ARG" | grep -Eq '^[0-9]+(\.[0-9]+){3}$'; then

    echo "IP address: $TERM_ARG"

    OCCURRENCES=$(grep -cwF "$TERM_ARG" "$LOGFILE")
    FAILED=$(grep -F "Failed password" "$LOGFILE" |
             grep -cwF "$TERM_ARG")

    echo "Occurrences: $OCCURRENCES"
    echo "Failed logins: $FAILED"

if [ "$FAILED" -eq 0 ]; then
        echo "Risk: NONE"
    elif [ "$FAILED" -lt 5 ]; then
        echo "Risk: LOW"
    elif [ "$FAILED" -lt 15 ]; then
        echo "Risk: MEDIUM"
    else
        echo "Risk: HIGH"
    fi
 echo "Firewall entries:"
    grep -wF "$TERM_ARG" case/logs/firewall.log || echo "No firewall entries"

    # IOC check
    if grep -qxF "$TERM_ARG" intel/iocs.txt; then
        echo "IOC: LISTED"
    else
        echo "IOC: NOT LISTED"
    fi

    FOUND=$OCCURRENCES

else

    echo "Username: $TERM_ARG"

    FAILED=$(grep -Fc "Failed password for $TERM_ARG " "$LOGFILE")
    ACCEPTED=$(grep -Fc "Accepted password for $TERM_ARG " "$LOGFILE")

    echo "Failed logins: $FAILED"
    echo "Accepted logins: $ACCEPTED"
 if awk -F',' -v user="$TERM_ARG" '$1 == user {found=1} END {exit !found}' intel/users.csv; then
        echo "Account: CURRENT"
    elif grep -qxF "$TERM_ARG" case/backups/users.old; then
        echo "Account: LEGACY"
    else
        echo "Account: UNKNOWN"
    fi

    FOUND=$((FAILED + ACCEPTED))
fi

if [ "$FOUND" -gt 0 ]; then
    exit 0
else
    echo "Search term not found in log"
    exit 6
fi
