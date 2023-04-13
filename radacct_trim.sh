#!/usr/bin/env bash
####!/bin/sh
#set -x
#MYSQL DETAILS
DATE=`date`
logger radacct_trim script started $DATE
SQLUSER="root"
SQLPASS="YOUR_PASSWORD"
DB="radius"
TBL_ARCH="radacct_archive"
TBL_ARCH_EXISTS=$(printf 'SHOW TABLES LIKE "%s"' "$TBL_ARCH")
MONTHS="12"
export MYSQL_PWD=$SQLPASS
CMD="mysql -u$SQLUSER --skip-column-names -s -e"
# This is one time step.
echo "
Script Started @ $DATE
"
echo "- Step 1 : Checking for DB: $DB / TABLE: $TBL_ARCH ..."
DBCHK=`mysqlshow --user=$SQLUSER $DB | grep -v Wildcard | grep -o $DB`
if [ "$DBCHK" == "$DB" ]; then
echo " > $DB DB found"
else
echo " > $DB not found. Creating now ..."
$CMD "create database if not exists $DB;"
fi
if [[ $(mysql -u$SQLUSER -e "$TBL_ARCH_EXISTS" $DB) ]]
then
echo " > $TBL_ARCH TABLE found IN DB: $DB"
else
echo " > $TBL_ARCH TABLE not found IN DB: $DB / Creating now ..."
$CMD "use $DB; create table if not exists $TBL_ARCH LIKE radacct;"
fi
 
# Start Action: copy data from radacct to new db/archive table
NOTULL_COUNT=`$CMD "use $DB; select count(*) from radacct WHERE acctstoptime is not null;"`
echo "- Step 2 : Found $NOTULL_COUNT records in radacct table , Now copying $NOTULL_COUNT records to $TBL_ARCH table ..."
$CMD "use $DB; INSERT IGNORE INTO $TBL_ARCH SELECT * FROM radacct WHERE acctstoptime is not null;"
echo "- Step 3 : Deleting $NOTULL_COUNT records old data from radacct table (which have acctstoptime NOT NULL) ..."
# --- Now Delete data from CURRENT RADACCT table so that it should remain fit and smart ins size
$CMD "use $DB; DELETE FROM radacct WHERE acctstoptime is not null;"
echo "- Step 4 : Copying old data from $TBL_ARCH older then $MONTHS months ..."
# --- Now Delete data from RADACCT_ARCHIVE table so that it should not grow either more than we required i.e 1 Year - one year archived data is enough IMO
$CMD "use $DB; DELETE FROM $TBL_ARCH WHERE date(acctstarttime) < (CURDATE() - INTERVAL $MONTHS MONTH);"
DATE=`date`
logger radacct_trim script ended with $NOTULL_COUNT records processed for trimming @ $DATE
echo "
radacct_trim script ended with $NOTULL_COUNT records processed for trimming @ $DATE"
