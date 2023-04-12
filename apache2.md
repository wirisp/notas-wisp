- Hay veces que apachemarca error al ejecutarse por lo que debemos:
- detenerlo
- Buscar el PID que esta ofuscado a eliminar
- eliminarlo
- volverlo a iniciar o hacer un reboot a la maquina.

_Necesitamos instalar esta aplicacion_
```
apt install net-tools
```
_Detenemos apache_
```
sudo systemctl stop apache2.service 
```
_Buscamos el PID que esta usando el puerto 80_
```
netstat -ltnp | grep :80
```
_Lo eliminamos con_
```
sudo kill -9 1047
```
_Despues detenemos e iniciamos nuevamente, si no, reboot_

```
sudo systemctl stop apache2.service 
sudo systemctl enable apache2.service 
sudo systemctl start apache2.service
sudo systemctl status apache2.service
```
