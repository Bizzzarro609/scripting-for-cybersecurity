#!/bin/bash

for FILE in case/evidence/* case/scripts/*; do
    TYPE=$(file -b "$FILE")
    if [[ "$FILE" == *.png ]]; then
        EXPECT="PNG"
    elif [[ "$FILE" == *.sh  ]]; then
        EXPECT="shell script"
    elif [[ "$FILE" == *.py ]]; then
        EXPECT="Python script"
    elif [[ "$FILE" == *.zip ]]; then
        EXPECT="Zip"
    elif [[ "$FILE" == *.txt || "$FILE" == *.md ]]; then
        EXPECT="text"
    else
        EXPECT=""
    fi

    if [ -z "$EXPECT" ]; then
        echo "?? $FILE — no expectation for this extension; detected: $TYPE"
    elif [[ "$TYPE" == *"$EXPECT"* ]]; then
        echo "OK $FILE — $TYPE"
    else
        echo "!! $FILE — expected $EXPECT, detected: $TYPE"
    fi
done
