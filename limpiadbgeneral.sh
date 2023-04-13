#!/bin/sh
#set -x
# Este script utiliza esta creado con los scripts senalados en este repositorio, es una union en uno solo
# Elimina usuarios con vigenvcia de 10 dias, limpia las bases de datos de hace 50 dias
SQLPASS="PASSSWDB"
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
#Copia usuarios a root, por lo cual es archivo debe existir o crearlo con
# touch /root/scripts/exp.txt
cp /tmp/expired.users.txt /root/scripts/exp.txt
# Parte 2 para limpiar la base de datos en radpostauth && raddact
mysql -uroot -e "use radius; DELETE FROM radpostauth WHERE authdate <= DATE_SUB(CURDATE(), INTERVAL 50 day);"
mysql -uroot -e "use radius; DELETE FROM radacct WHERE acctstarttime <= DATE_SUB(CURDATE(), INTERVAL 50 day);"
echo "Base de datos limpiada correctamente"
