# Oracle Password Expiration Check

## Overview
This repository contains a simple shell script that checks Oracle database users with expired or soon-to-expire passwords and generates a readable report for DBAs and security teams. It is designed to help prevent incidents caused by locked or expired application accounts in production environments with strict password policies.

## Features
- Lists Oracle users whose passwords are:
  - Already expired
  - Expiring soon (based on a configurable threshold in days)
- Uses information from DBA_USERS
- Outputs a clean, grep-friendly report (pipe-separated)
- Can be scheduled via cron to run daily
- Easy to extend to:
  - Send email alerts
  - Generate HTML reports
  - Integrate with monitoring tools

## Example query used
The core logic of the script is based on a query like:

SELECT username,
       account_status,
       expiry_date
  FROM dba_users
 WHERE account_status LIKE 'EXPIRED%'
    OR expiry_date <= SYSDATE + :days_threshold
 ORDER BY expiry_date;

## Requirements
- Linux environment
- Bash
- SQL*Plus client installed
- Oracle environment configured (ORACLE_HOME, ORACLE_SID, PATH)
- User with access to DBA_USERS (e.g. SYS, SYSTEM, or a privileged technical account)

## Usage
1. Clone the repository:

git clone https://github.com/guborges/oracle-password-expiration-check.git
cd oracle-password-expiration-check

2. Edit the script and configure:
- The database connection (OS authentication or connect string)
- The threshold (in days) for “expiring soon” users

3. Make the script executable:

chmod +x check_password_expiration.sh

4. Run the script:

./check_password_expiration.sh
# or, using a connect string:
./check_password_expiration.sh "system/password@TNS"

5. Example output:

Threshold (days): 7
=================================
USERNAME|ACCOUNT_STATUS|EXPIRY_DATE
APP_USER|EXPIRED(GRACE)|2025-12-15 23:59:59
REPORT_USER|OPEN (EXPIRING SOON)|2025-12-16 23:59:59

## File structure
oracle-password-expiration-check/
├── check_password_expiration.sh
└── README.md

## Notes
This script is intended as a lightweight operational tool and can be adapted to different environments such as:
- CDB/PDB
- Multiple databases on the same host
- HTML/CSV generation
- Email notifications

It is especially useful in production environments where expired accounts may impact critical applications and batch jobs.

## License
MIT License
