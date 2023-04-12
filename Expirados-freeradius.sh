#!/bin/sh
#set -x
# Busca el usuario en la tabla usadas con un inicio de sesion de hace 10 dias o mas y que esten en los grupos especificados.
# Hace un backup de esos usuarios temporal a un archivo de texto el cual se sobreescribe en la proxima ejecucion.
# Elimina los usuarios encontrados desde tablas radcheck radacct radusergroup userinfo
SQLPASS="PasswdDb"
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
echo "$USERNAME —- user record from all relevant tables"
mysql -uroot -e "use radius; DELETE FROM radcheck WHERE username = '$USERNAME';"
mysql -uroot -e "use radius; DELETE FROM radacct WHERE username = '$USERNAME';"
mysql -uroot -e "use radius; DELETE FROM radusergroup WHERE username = '$USERNAME';"
mysql -uroot -e "use radius; DELETE FROM userinfo WHERE username = ‘$USERNAME';"

done
