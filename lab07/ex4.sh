#!/bin/bash

LOG="case/logs/access.log"

if grep -q "sqlmap" "$LOG"; then
	echo "Scanning tool activity detected"
else 
	echo "No scanning tool activity"
fi
