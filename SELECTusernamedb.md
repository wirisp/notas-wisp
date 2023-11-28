### Seleccionar usuarios o listarlos en la base de datos
- Inicia sesion en la db
```
mysql -u root -p radius
```
- Listado por Nombre en informacion
```
SELECT username FROM userinfo WHERE userinfo.firstname like 'LEONARDA HUAYAL%';
```
- Listado por grupo o perfil
```
SELECT username FROM radusergroup WHERE groupname = '30dMensual';
```
- Listado por Fecha de creacion
```
SELECT username FROM userinfo WHERE creationdate like '2023-05-25 07:1%';
```
