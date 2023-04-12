## Cuando el DNS de nuestra maquina no hace resoluciones entonces:
- Editamos el archivo `/etc/resolvconf/resolv.conf.d/head`

```
nano /etc/resolvconf/resolv.conf.d/head
```
- Dentro agregamos los DNS propios o los de cloudflare en este caso.

```
nameserver 1.1.1.1
nameserver 1.0.0.1
```
- Tambien podemos agregar los DNS en el siguiente archivo.

```
nano /etc/systemd/resolved.conf
```
- y Agregamos

```
DNS=8.8.8.8
```
- Despues reiniciamos el servicio con

```
sudo systemctl restart systemd-resolved
```
- Otra opcion pero temporal el agregar los DNS en el archivo `resolv.conf`

```
nano /etc/resolv.conf
```
- Agregar

```
nameserver 8.8.8.8
```
- Reiniciar el servicio con

```
sudo systemctl restart systemd-resolved.service
```
