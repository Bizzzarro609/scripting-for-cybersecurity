#!/bin/bash

LOG="case/nested/archive/old.log"

while IFS= read -r INDICATOR; do
    if grep -qwF "$INDICATOR" "$LOG"; then
        echo "First match in $LOG: $INDICATOR — stopping search."
        break
    fi
done < intel/iocs.txt

echo "Search finished."
