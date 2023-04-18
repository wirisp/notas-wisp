## Notas-wisp
Apuntes ,notas ,errores y algunas soluciones de wisp

## Script de backup automatico en radius
- Crear una carpeta para guardar los backups

```
mkdir -p backupdb && cd backupdb
```

- Descargar el archivo ,cambiarle dentro el password de la base de datos, asi como el lugar la ruta `backupfolder="/root/backupdb/"`

```
wget https://raw.githubusercontent.com/wirisp/notas-wisp/main/backupdbradius.sh -O backupdbradius.sh
```
- Ahora lo ejecutas con
```
./backupdbradius.sh
```

## Script limpiadb.sh
- Elimina fichas por ejemplo que hayan iniciado sesion hace 10 dias, o los que le especifiquemos, como vigencia
- En la parte 2 elimina entradas e historial de conexiones y informacion de pagos de hasta 30 dias atras,lo cual reduce el la base de datos.

```
#!/bin/sh
#set -x
# Este script elimina fichas de hace 10 dias de uso, y tambien limpia las bases de datos de hace 30 dias.
# Cambiar el password de tu DB
SQLPASS="84Uniq@"
export MYSQL_PWD=$SQLPASS
> /tmp/expired.users.txt

# extrae y despues elimina las fichas de hace 10 dias de haberlas introducido a un dispocitivo y de los perfiles 2hPausada y 12hPasauada
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
mysql -uroot -e "use radius; DELETE FROM userbillinfo WHERE username = '$USERNAME';"

done
#Copia usuarios a root
cp /tmp/expired.users.txt /root/scripts/exp.txt
# Parte 2 para limpiar la base de datos en radpostauth && raddact
mysql -uroot -e "use radius; DELETE FROM radpostauth WHERE authdate <= DATE_SUB(CURDATE(), INTERVAL 30 day);"
mysql -uroot -e "use radius; DELETE FROM radacct WHERE acctstarttime <= DATE_SUB(CURDATE(), INTERVAL 30 day);"
mysql -uroot -e "use radius; DELETE FROM userbillinfo WHERE creationdate <= DATE_SUB(CURDATE(), INTERVAL 30 day);"
mysql -uroot -e "use radius; DELETE FROM radpostauth WHERE authdate <= DATE_SUB(CURDATE(), INTERVAL 30 day);"
echo "Base de datos limpiada correctamente"
```


## Eliminar usuarios expirados o que iniciaron sesion desde hace ciertos dias por ejemplo 10

Este script busca en la base de datos especificada y tambien en los grupos los usuarios que hayan iniciado sesion hace 10 dias, y los elimina
_Yo vendo fichas o vouchers y la vigencia despues del primer uso es de 10 dias, los creo en lote o batch por lo que uso el grupo para la busqueda en el script_

- Descargamos el script
```
wget https://raw.githubusercontent.com/wirisp/notas-wisp/main/Expirados-freeradius.sh -O expirados.sh
```
- Creamos un archivo de texto para tener un bk de los usuarios a eliminar, de igual manera en la siguiente ejecucion se sobreescribira con los proximos.

```
touch /root/exp.txt
```
- Editamos dentro del archivo ejecutable el password de nuestra base de datos y acomodamos los grupos o perfiles de nuestros usuarios.
- ejecutamos el script con
```
./expirados.sh
```

## Archivar conexiones de la tabla Raddact para reducirla
[x] Se archivaran las conexiones que posterioresa X dias. (cambiar X dias en el script)

- Creamos una carpeta con el script
```
mkdir -p scripts
cd scripts
```
- Ahora descargamos el siguiente script y editamos el password de la db 
```
wget https://raw.githubusercontent.com/wirisp/notas-wisp/main/radacct_trim.sh -O radacct_trim.sh
```
- Le damos permisos de ejecucion con `chmod +x *sh` y lo ejecutamos con :

```
./radacct_trim.sh
```
- Ahora en tu daloradius `http://IP/daloradius/acct-all.php` veras una reduccion.
- Tambien puedes agregarlo a ejecturase automaticamente con
```
export VISUAL=nano; crontab -e
```
- y Dentro colocas ,por ejemplo cada dia a las 20 hrs.
```
0 20 * * * /root/scripts/radacct_trim.sh
```
