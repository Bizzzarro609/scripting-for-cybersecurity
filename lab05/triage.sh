#!/bin/bash

CASE_DIR="case"
REPORT="triage-report-auto.txt"

read -p "Enter the analyst name: " ANALYST
read -p "Enter the case reference: " CASE_REF

PYTHON_FILES=$(find "$CASE_DIR" -type f -name "*.py" | wc -l)
SHELL_SCRIPTS=$(find "$CASE_DIR" -type f -name "*.sh" | wc -l)

TOTAL_FILES=$(find "$CASE_DIR" -type f | wc -l)
TOTAL_DIRECTORIES=$(find "$CASE_DIR" -type d | wc -l)
LOG_FILES=$(find "$CASE_DIR" -type f -name "*.log" | wc -l)
CONFIG_FILES=$(find "$CASE_DIR" -type f -name "*.conf" | wc -l)
EMPTY_FILES=$(find "$CASE_DIR" -type f -empty | wc -l)
ARCHIVES=$(find "$CASE_DIR" -type f -name "*.zip" | wc -l)

SCRIPTS=$((PYTHON_FILES + SHELL_SCRIPTS))

cat > "$REPORT" <<EOF
Triage Report
Analyst: $ANALYST
Case Reference: $CASE_REF
Date: $(date)

Total Files: $TOTAL_FILES
Total Directories: $TOTAL_DIRECTORIES
Python Files: $PYTHON_FILES
Shell Scripts: $SHELL_SCRIPTS
Log Files: $LOG_FILES
Configuration Files: $CONFIG_FILES
Empty Files: $EMPTY_FILES
Archives: $ARCHIVES

Files containing admin:
EOF

grep -rl "admin" "$CASE_DIR" >> "$REPORT"

echo "" >> "$REPORT"
echo "Evidence File Types:" >> "$REPORT"
file "$CASE_DIR"/evidence/* >> "$REPORT"

echo "" >> "$REPORT"
echo "Scripts (Python + shell): $SCRIPTS" >> "$REPORT"

echo "Triage report created: $REPORT"
