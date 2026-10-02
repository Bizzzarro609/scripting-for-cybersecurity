#!/bin/bash

read -p "Enter a username to look up: " TARGET_USER
echo "Searching the account list for: $TARGET_USER"
grep "$TARGET_USER" intel/users.csv
