#!/bin/bash

if [ ! -d exam-data ]; then
    echo "Error: exam-data directory not found" >&2
    exit 1
fi

count=0
total=0

while IFS= read -r -d '' file; do
    if [ ! -r "$file" ]; then
        echo "Error: Cannot read $file" >&2
        exit 1
    fi

    lines=$(wc -l < "$file")
    printf '%s : %s lines\n' "$file" "$lines"
    count=$((count + 1))
    total=$((total + lines))
done < <(find exam-data -type f -name '*.log' -print0)

echo "Logs found: $count"
echo "Total lines: $total"
exit 0
