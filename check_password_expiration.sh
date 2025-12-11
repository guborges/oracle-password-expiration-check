#!/usr/bin/env bash
#
# check_password_expiration.sh
#
# Lists Oracle users with expired or soon-to-expire passwords.
# Output is pipe-separated for easy parsing and automation.
#
# Created by: Gustavo Borges Evangelista

############################################################
# Configuration
############################################################

# Threshold (in days) to consider “expiring soon”
DAYS_THRESHOLD=7

# Optional connect string:
# - If empty: uses "/ as sysdba"
# - If provided: uses that connection
CONNECT_STRING="$1"

############################################################
# Helper functions
############################################################

error_exit() {
  echo "ERROR: $1"
  exit 1
}

check_env() {
  if ! command -v sqlplus >/dev/null 2>&1; then
    error_exit "sqlplus not found in PATH. Configure ORACLE_HOME and PATH."
  fi

  if [ -z "$CONNECT_STRING" ] && [ -z "$ORACLE_SID" ]; then
    error_exit "ORACLE_SID not set and no connect string provided."
  fi
}

run_sql() {
  if [ -n "$CONNECT_STRING" ]; then
    sqlplus -s "$CONNECT_STRING" <<EOF
SET PAGES 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF LINES 300 COLSEP '|' TRIMSPOOL ON
SELECT username,
       account_status,
       TO_CHAR(expiry_date, 'YYYY-MM-DD HH24:MI:SS')
  FROM dba_users
 WHERE (account_status LIKE 'EXPIRED%'
    OR  expiry_date <= SYSDATE + $DAYS_THRESHOLD)
 ORDER BY expiry_date;
EXIT
EOF
  else
    sqlplus -s "/ as sysdba" <<EOF
SET PAGES 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF LINES 300 COLSEP '|' TRIMSPOOL ON
SELECT username,
       account_status,
       TO_CHAR(expiry_date, 'YYYY-MM-DD HH24:MI:SS')
  FROM dba_users
 WHERE (account_status LIKE 'EXPIRED%'
    OR  expiry_date <= SYSDATE + $DAYS_THRESHOLD)
 ORDER BY expiry_date;
EXIT
EOF
  fi
}

############################################################
# Main
############################################################

check_env

echo "Threshold (days): $DAYS_THRESHOLD"
echo "================================="
echo "USERNAME|ACCOUNT_STATUS|EXPIRY_DATE"

RESULT="$(run_sql)"

# Remove empty lines
echo "$RESULT" | sed '/^$/d'
