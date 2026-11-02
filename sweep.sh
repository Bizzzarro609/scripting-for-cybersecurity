#!/bin/bash

ioc_file="exam-data/intel/iocs.txt"
log_dir="exam-data/case/logs"
evidence_dir="exam-data/case/evidence"

if [ "$#" -ne 0 ]; then
    echo "Usage: $0" >&2
    exit 1
fi

if [ ! -f "$ioc_file" ] || [ ! -r "$ioc_file" ] ||
   [ ! -d "$log_dir" ] || [ ! -d "$evidence_dir" ]; then
    echo "Error: Check input files and directories" >&2
    exit 1
fi

total=0

# Part 1: IOC Sweep
# Read one complete indicator per array element, preserving spaces.
mapfile -t indicators < "$ioc_file"
for indicator in "${indicators[@]}"; do
    indicator=$(printf '%s' "$indicator" | tr -d '\r')
    [ -z "$indicator" ] && continue
    logs_found=0

    for logfile in "$log_dir"/*.log; do
        [ -f "$logfile" ] || continue

        count=$(grep -Fwc -- "$indicator" "$logfile")
        result=$?
        if [ "$result" -gt 1 ]; then
            echo "Error: Cannot search $logfile" >&2
            exit 1
        fi

        if [ "$count" -gt 0 ]; then
            echo "$indicator $(basename "$logfile") $count"
            logs_found=$((logs_found + 1))
            total=$((total + count))
        fi
    done

    echo "$indicator found in $logs_found logs"
done

echo "Total matching lines: $total"

# Part 2: Hash Check
for file in "$evidence_dir"/*; do
    [ -f "$file" ] || continue

    if [ ! -r "$file" ]; then
        echo "Error: Cannot read $file" >&2
        exit 1
    fi

    digest=$(md5sum < "$file")
    if [ "$?" -ne 0 ]; then
        echo "Error: Cannot hash $file" >&2
        exit 1
    fi
    hash=$(printf '%s\n' "$digest" | awk '{print $1}')

    matches=$(tr -d '\r' < "$ioc_file" | grep -Fxc -- "$hash")
    result=$?
    if [ "$result" -gt 1 ]; then
        echo "Error: Cannot compare hashes" >&2
        exit 1
    fi

    if [ "$matches" -gt 0 ]; then
        echo "KNOWN BAD: $file"
    else
        echo "CLEAN: $file"
    fi
done

exit 
