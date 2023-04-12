# notas-wisp
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
