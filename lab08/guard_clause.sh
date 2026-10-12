#!/bin/bash

FILE=$1

if [ -z "$FILE" ]; then
    echo "Usage: $0 <file>" >&2
    exit 1
fi

if [ -f "$FILE" ] && [ -r "$FILE" ] && [ -s "$FILE" ]; then
    echo "$FILE is a readable, non-empty file — proceeding."
elif [ ! -f "$FILE" ];then
    echo "$FILE is not a regular file."
    exit 2
elif [ ! -r "$FILE" ]; then
    echo "$FILE is unreadable."
    exit 3
elif [ ! -s "$FILE" ]; then
    echo "$FILE is empty." >&2
    exit 4
fi
