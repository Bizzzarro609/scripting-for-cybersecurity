#!/bin/bash

read -p "Enter a username to look up: " TARGET_USER
read -p "Enter a department to look up: " TARGET_DEPARTMENT
echo "Searching the account list for: $TARGET_USER"
grep "$TARGET_USER" intel/users.csv
grep "$TARGET_DEPARTMENT" intel/users.csv
