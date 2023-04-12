#!/bin/sh
#set -x
# This script delets users who have expired 2 months ago. and then delete there records from all tables.
# Syed Jahanzaib / June 2019
SQLPASS="niq@84U"
export MYSQL_PWD=$SQLPASS
> /tmp/expired.users.txt

#mysql -uroot -e “use radius; select username from rm_users where expiration BETWEEN ‘2010-01-01’ AND ‘2019-04-30’;” |sort > /tmp/expired.users.txt

# Fetch users who have expired 2 months ago & before, (using expired date), BE CAREFUL WHEN USING THIS
mysql -uroot -e "use radius; SELECT username FROM usadas WHERE ant <= DATE_SUB(CURDATE(), INTERVAL 10 day) and (groupname = '2hPausada' OR groupname = '12hPausada')" |sort > /tmp/expired.users.txt
num=0
cat /tmp/expired.users.txt | while read users
do
num=$[$num+1]
USERNAME=`echo $users | awk '{print $1}'`
echo "$USERNAME"
mysql -uroot -e "use radius; DELETE FROM userinfo WHERE username = '$USERNAME';"
mysql -uroot -e "use radius; DELETE FROM radcheck WHERE username = '$USERNAME';"
mysql -uroot -e "use radius; DELETE FROM radacct WHERE username = '$USERNAME';"
mysql -uroot -e "use radius; DELETE FROM radusergroup WHERE username = '$USERNAME';"

done
#Copia usuarios a root
cp /tmp/expired.users.txt /root/exp.txt
