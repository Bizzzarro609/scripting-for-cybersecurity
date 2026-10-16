#!/bin/bash

CLIENTS=$(awk '{print $1}' case/logs/access.log | sort -u)

for IP in $CLIENTS; do
    COUNT=$(awk -v ip="$IP" '$1 == ip {count++} END {print count+0}' case/logs/access.log)
    if grep -qxF "$IP" intel/iocs.txt; then
        echo "$IP ($COUNT requests): already in IOC list"
    else
        echo "$IP ($COUNT requests): NOT in IOC list — candidate for new indicator"
    fi
done
