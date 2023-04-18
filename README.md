## Notas-wisp
Apuntes ,notas ,errores y algunas soluciones de wisp

## Uso de la base de datos de ejemplo `dbname.sql`
Esta base de datos cuenta con las siguientes tablas
```
MariaDB [radius]> show tables;
+------------------------+
| Tables_in_radius       |
+------------------------+
| batch_history          |
| billing_history        |
| billing_merchant       |
| billing_paypal         |
| billing_plans          |
| billing_plans_profiles |
| billing_rates          |
| cui                    |
| detalle                |
| diarias                |
| dictionary             |
| fichas                 |
| hotspots               |
| invoice                |
| invoice_items          |
| invoice_status         |
| invoice_type           |
| lotes                  |
| nas                    |
| node                   |
| operators              |
| operators_acl          |
| operators_acl_files    |
| payment                |
| payment_type           |
| proxys                 |
| radacct                |
| radacct_archive        |
| radcheck               |
| radgroupcheck          |
| radgroupreply          |
| radhuntgroup           |
| radippool              |
| radpostauth            |
| radreply               |
| radusergroup           |
| realms                 |
| resumen                |
| totales                |
| usadas                 |
| userbillinfo           |
| userinfo               |
| wimax                  |
+------------------------+
```
- Incluye perfiles creados para tiempo corrido ,tiempo pausado y mensuales de cliente recurrente.
![image](https://user-images.githubusercontent.com/13319563/232824941-93c8fd22-d054-48af-a71e-d59893775581.png)
- **12hPausada**,**3HrPausada**,**2hPausada**  ; Tiempo pausado de 12h, 3h, 2h
- **2Hrs-unlimit** ; Tiempo pausado 2 h sin velocidad especificada.
- **30dMensual** ; Tiempo mensual recurrente (al crear usuario necesita el atributo `Wispr session terminatetime` )
- **MENSUAL-1USO** ; Perfil tiempo mensual para fichas de un solo uso, no recurrente. =  tiempo corrido 1 mes.

#### Crear fichas para cliente pausado de 2hPausada y 12hPausada
- Estas fichas contienen los siguientes atributos **Check** por ejemplo para la de 2h pausada. 
- El tiempo comienza a correr a partir de que el voucher/ficha es introducida por primera vez en el dispositivo.

```
MariaDB [radius]> SELECT * FROM radgroupcheck WHERE groupname = '2hPausada';
+----+-----------+------------------+----+-------+
| id | groupname | attribute        | op | value |
+----+-----------+------------------+----+-------+
|  5 | 2hPausada | Max-All-Session  | := | 7200  |
| 15 | 2hPausada | Fall-Through     | := | Yes   |
| 16 | 2hPausada | Simultaneous-Use | := | 1     |
+----+-----------+------------------+----+-------+
```
- Y para los atributos **Reply** es.
```
MariaDB [radius]> SELECT * FROM radgroupreply WHERE groupname = '2hPausada';
+----+-----------+-----------------------+----+---------------------------------------------+
| id | groupname | attribute             | op | value                                       |
+----+-----------+-----------------------+----+---------------------------------------------+
| 29 | 2hPausada | Mikrotik-Rate-Limit   | := | 512K/2M 1M/3M 384K/1500K 16/12 8 256K/1000K |
| 30 | 2hPausada | Acct-Interim-Interval | := | 60                                          |
+----+-----------+-----------------------+----+---------------------------------------------+
```
-  Para crear un lote o batch simplemente vas a daloradius, click ,Managment > Batch add users > Le pones un nombre o ID unico, seleccionas un Hotspot (opcional), longuitud de nombre de usuario, cantidad de fichas, longuitud de password , el group (perfil 2hPausada) y el plan (opcional).

#### Fichas **MENSUAL-1USO** o tiempo corrido de un solo uso.
Estas fichas son para tiempo corrido, se puede ajustar al tiempo requerido, en este ejemplo se tomo un mes.
El tiempo comienza a correr a partir de que el voucher/ficha es introducida por primera vez en el dispositivo.
- Los atributos **Check** para este perfil son.

```
MariaDB [radius]> SELECT * FROM radgroupcheck WHERE groupname = 'MENSUAL-1USO';
+----+--------------+------------------+----+---------+
| id | groupname    | attribute        | op | value   |
+----+--------------+------------------+----+---------+
|  9 | MENSUAL-1USO | Access-Period    | := | 2592000 |
| 10 | MENSUAL-1USO | Fall-Through     | := | Yes     |
| 11 | MENSUAL-1USO | Simultaneous-Use | := | 1       |
+----+--------------+------------------+----+---------+
```
- Los atributos **Reply** para este perfil son.
```
MariaDB [radius]> SELECT * FROM radgroupreply WHERE groupname = 'MENSUAL-1USO';
+----+--------------+-----------------------+----+---------------------------------------------+
| id | groupname    | attribute             | op | value                                       |
+----+--------------+-----------------------+----+---------------------------------------------+
| 37 | MENSUAL-1USO | Mikrotik-Rate-Limit   | := | 512K/2M 1M/3M 384K/1500K 16/12 8 256K/1000K |
| 26 | MENSUAL-1USO | Acct-Interim-Interval | := | 60                                          |
+----+--------------------------------------+----+---------------------------------------------+
```
- Igualmente como en el perfil anterior es posible crear lotes o Batchs.
- El atributo que controla el tiempo o especifica el tiempo es el `Access-Period` en `Check` con `Op` `:=`y es especificado en segundos, por lo que necesitas convertir tu tiempo requerido a segundos.

#### Crear usuario recurrente Mensual
Al crear un usuario recurrente es posible especificarle un tiempo de finalizacion de la ficha , por lo que el tiempo inicia a partir de ser creada y no al ser ingresada al dispocitivo, al vencerse el MES por ejemplo, es posible cambiarle la fecha a otra o extenderle el timpo requerido.

- Los atributos para el apartado **Check** del perfil son:

```
MariaDB [radius]> SELECT * FROM radgroupcheck WHERE groupname = '30dMensual';
+----+------------+------------------+----+-------+
| id | groupname  | attribute        | op | value |
+----+------------+------------------+----+-------+
| 17 | 30dMensual | Fall-Through     | := | Yes   |
| 18 | 30dMensual | Simultaneous-Use | := | 1     |
+----+------------+------------------+----+-------+
```
- Los atributos para el apartado **Reply** son:

```
MariaDB [radius]> SELECT * FROM radgroupreply WHERE groupname = '30dMensual';
+----+------------+-----------------------+----+----------------------------------------------------------------------+
| id | groupname  | attribute             | op | value                                                                |
+----+------------+-----------------------+----+----------------------------------------------------------------------+
| 32 | 30dMensual | Acct-Interim-Interval | := | 60                                                                   |
| 46 | 30dMensual | Mikrotik-Rate-Limit   | := | 512K/2M 1M/3M 384K/1500K 16/12 8 256K/1000K                          |
| 41 | 30dMensual | WISPr-Redirection-URL | =  | https://dailyverses.net/es/versiculo-de-la-biblia-al-azar/proteccion |
+----+------------+-----------------------+----+----------------------------------------------------------------------+
```
- Crear usuario recurrente para el perfil  `30dMensual` recurrente.
1. Nos vamos a daloradius
2. Managmente > New user
3. username = USER1  , password = PASS1  , group = 30dMensual
4. Ahora sin aplicar nos vamos a attributes y agregamos el siguiente atributo.

![image](https://user-images.githubusercontent.com/13319563/232839483-d259fb76-4d13-42a5-b27a-3fa69f562be4.png)
El atributo agregado es : `WISPr-Session-Terminate-Time`
El valor es de acuerdo a la fecha de finalizacion del usuario, por ejemplo `2023-12-24T17:00:00` esta finaliza el 24 de diciembre de 2023 a las 5 pm.
5. Das click en apply.

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
- Toma los usuarios de las fichas desde la tabla `usadas` ; la base de datos usada para daloradius es la que se encuentra en este repositorio llamada `dbname.sql` por lo que puedes importarla a tu daloradius, recuerda hacer un backup de tu anterior.
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
mysql -uroot -e "use radius; SELECT username FROM usadas WHERE min <= DATE_SUB(CURDATE(), INTERVAL 10 day) and (groupname = '2hPausada' OR groupname = '12hPausada')" |sort > /tmp/expired.users.txt
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
