#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <file>" >&2
    exit 1
fi

file="$1"

if [ ! -f "$file" ]; then
    echo "Error: File does not exist or is not a regular file" >&2
    exit 2
fi

if [ ! -r "$file" ]; then
    echo "Error: Cannot read file" >&2
    exit 2
fi

if [ ! -s "$file" ]; then
    echo "Error: File is empty" >&2
    exit 3
fi

lines=$(wc -l < "$file")
failed=$(grep -Fc "Failed password" < "$file" || true)
accepted=$(grep -Fc "Accepted password" < "$file" || true)

first=$(head -n 1 < "$file" | awk '{print $1, $2, $3}')
last=$(tail -n 1 < "$file" | awk '{print $1, $2, $3}')

echo "File     : $file"
echo "Lines    : $lines"
echo "Failed   : $failed"
echo "Accepted : $accepted"
echo "First    : $first"
echo "Last     : $last"

exit 0
