#!/bin/sh
#set -x
# Este script elimina las conexiones creadas en http://IP/daloradius/rep-lastconnect.php de hace cierto tiempo
SQLPASS="23River@B"
export MYSQL_PWD=$SQLPASS
mysql -uroot -e "use radius; DELETE FROM radpostauth WHERE authdate <= DATE_SUB(CURDATE(), INTERVAL 50 day);"
#mysql -uroot -e "use radius; DELETE FROM radacct WHERE acctstarttime <= DATE_SUB(CURDATE(), INTERVAL 50 day);"
echo "Base de datos limpiada correctamente"
