#!/bin/bash

echo "Counting accepted passwords..."
for FILE in case/logs/*.log; do
    COUNT=$(grep -c "Accepted password" "$FILE")
    echo "$FILE: $COUNT accepted logins"
done
