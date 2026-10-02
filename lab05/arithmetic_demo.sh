#!/bin/bash

PYTHON_FILES=2
SHELL_SCRIPTS=1
LOG_FILES=4
CONFIG_FILES=3
TOTAL_FILES=24

SCRIPTS=$((PYTHON_FILES + SHELL_SCRIPTS))
OTHER=$((TOTAL_FILES - SCRIPTS - LOG_FILES - CONFIG_FILES))
PERCENT_LOGS=$((LOG_FILES * 100 / TOTAL_FILES))
PERCENT_SCRIPTS=$((LOG_FILES / TOTAL_FILES * 100))
echo "Scripts (Python + shell) : $SCRIPTS"
echo "Logs                     : $LOG_FILES"
echo "Configuration files      : $CONFIG_FILES"
echo "Everything else          : $OTHER"
echo "Logs as % of all files   : $PERCENT_LOGS%"
echo "Logs as % of scrypt files : $SHELL_SCRIPTS%"
echo "Total files: TOTAL=$((LOG_FILES + "abc"))"
