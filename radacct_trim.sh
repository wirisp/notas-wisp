#!/usr/bin/env bash
####!/bin/sh
#set -x
#MYSQL DETAILS
SQLUSER="root"
SQLPASS="YOUR_PASSWORD"
DB="radius"
Days="20"
export MYSQL_PWD=$SQLPASS
CMD="mysql -u$SQLUSER --skip-column-names -s -e"
# This is one time step.
echo "- Step 1 : Checking for DB: $DB / TABLE: $TBL_ARCH ..."
DBCHK=`mysqlshow --user=$SQLUSER $DB | grep -v Wildcard | grep -o $DB`
if [ "$DBCHK" == "$DB" ]; then
echo " > $DB DB found"
else
echo " > $DB not found. Creating now ..."
$CMD "create database if not exists $DB;"
fi
 
# Start Action: copy data from radacct to new db/archive table
NOTULL_COUNT=`$CMD "use $DB; select count(*) from radacct WHERE acctstarttime <= DATE_SUB(CURDATE(), INTERVAL $Days day);"`
echo "- Step 3 : Eliminando $NOTULL_COUNT entradas de la tabla radacct (Fecha posterior a $Days) ..."
$CMD "use $DB; DELETE FROM radacct WHERE acctstarttime <= DATE_SUB(CURDATE(), INTERVAL $Days day);"
echo "Finalizada la limpieza de la tabla raddact"
