## Limitar usuario a un solo NAS o mikrotik

- Busca en tu servidor el archivo que contenga `copy_request_to_tunnel`

```
grep -rl "copy_request_to_tunnel" /etc
```

por ejemplo eso se encuentra en :
```
nano /etc/freeradius/3.0/mods-available/eap
```
- Edita el archivo y donde encuentres:
```
copy_request_to_tunnel = no
```
Cambialo a yes.
```
copy_request_to_tunnel = yes
```
Tambien cambia lo que diga 
```
use_tunneled_reply = no
```
igualmente a yes
```
use_tunneled_reply = yes
```
- Ahora ve a tu daloradius `IP/daloradius` y agrega a tu usuario o (perfil) este atributo `NAS-Identifier`, recuerda que si lo agregas a un perfil, ese perfil sera  solo para ese NAS o Mikrotik en mi caso.

Suponiendo que tu mikrotik tiene el identity `Rb01` en `/system identity print` entonces tu NAS-identifier sera `Rb01`
Agrega el atributo NAS-Identifier al daloradius:

**Atribbute:** NAS-Identifier
**Value:** Rb01
**Op:** ==
**Target:** Check

- Ahora reinicia el servidor freeradius y testea tu usuario en varios NAS ,observaras que solamente te deja conectarte al especificado.
