#!/bin/bash

read -p "Enter a username: " USERNAME
read -s -p "Enter a password: " PASSWORD
echo "Username  : $USERNAME"
echo "" 
echo "Password captured (length: ${#PASSWORD} characters)" 
