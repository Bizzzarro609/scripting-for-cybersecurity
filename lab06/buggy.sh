#!/bin/bash

if [ ! -f "$1" ]; then
    echo "Error: file not found"
    exit 1
fi

echo "Continuing anyway..."
exit 0
