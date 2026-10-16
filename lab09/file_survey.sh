#!/bin/bash

FILES_SURVEYED=0
FILES_FLAGGED=0
TOTAL_IOC_MATCHES=0

for DIR in case/evidence case/scripts case/logs; do
    for FILE in "$DIR"/*; do
        # Skip anything that is not a regular file
        [[ -f "$FILE" ]] || continue

        FILES_SURVEYED=$((FILES_SURVEYED + 1))

        SIZE=$(wc -c < "$FILE")
        SIZE=${SIZE//[[:space:]]/}
        TYPE=$(file -b "$FILE")
        HASH=$(sha256sum "$FILE" | awk '{print $1}')

        # Determine expected type from file extension
        case "$FILE" in
            *.png) EXPECT="PNG" ;;
            *.sh) EXPECT="shell script" ;;
            *.py) EXPECT="Python script" ;;
            *.zip) EXPECT="Zip" ;;
            *.txt|*.md) EXPECT="text" ;;
            *) EXPECT="" ;;
        esac

        # Flag extension/type mismatches
        FLAG=""
        if [[ -n "$EXPECT" && "$TYPE" != *"$EXPECT"* ]]; then
            FLAG="!!"
            FILES_FLAGGED=$((FILES_FLAGGED + 1))
        fi

        echo "${FLAG}File: $FILE"
        echo "  Size: $SIZE bytes"
        echo "  Type: $TYPE"

        # Print line count for text files
        if [[ "$TYPE" == *text* || "$TYPE" == *Text* ]]; then
            LINES=$(wc -l < "$FILE")
            echo "  Lines: $LINES"
        fi

        echo "  SHA-256: $HASH"

        # Check IOC matches in log files
        if [[ "$FILE" == *.log ]]; then
            DISTINCT=0
            IOC_LINES=0

            if [[ -f intel/iocs.txt ]]; then
                while IFS= read -r IOC || [[ -n "$IOC" ]]; do
                    [[ -z "$IOC" ]] && continue

                    if grep -Fq -- "$IOC" "$FILE"; then
                        DISTINCT=$((DISTINCT + 1))
                    fi
                done < intel/iocs.txt

                if [[ -s intel/iocs.txt ]]; then
                    IOC_LINES=$(grep -Ff intel/iocs.txt "$FILE" | wc -l)
                    IOC_LINES=${IOC_LINES//[[:space:]]/}
                fi
            fi

            TOTAL_IOC_MATCHES=$((TOTAL_IOC_MATCHES + DISTINCT))

            echo "  Distinct IOC indicators: $DISTINCT"
            echo "  IOC indicator lines: $IOC_LINES"
        fi

        echo
    done
done

echo "===== SURVEY SUMMARY ====="
echo "Files surveyed: $FILES_SURVEYED"
echo "Files flagged: $FILES_FLAGGED"
echo "Total IOC matches: $TOTAL_IOC_MATCHES"
