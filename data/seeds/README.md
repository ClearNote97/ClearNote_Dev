# data/seeds — Datos semilla

Datos mínimos y estables para inicializar la aplicación (catálogos base, usuarios de ejemplo).
Deben ser pequeños y **versionables**. No poner aquí datos reales de cliente ni PII.

## Patrón: un seed de credenciales debe CONVERGER al secret file

Si agregas un seed que crea un usuario con contraseña (p. ej. un admin inicial), **no lo hagas
insert-only**. Un seed que solo "inserta si no existe" **ignora cambios posteriores**: si rotas la
contraseña en `secrets/…` después del primer arranque, el login seguirá fallando porque el hash
quedó con la **primera** contraseña.

**Regla:** el **secret file es la fuente de verdad** y el seed debe **converger** a él:
- si el usuario no existe → crearlo con el hash de la contraseña del archivo;
- si existe pero la contraseña del archivo ya no casa → **re-hashear y actualizar** (y alinear su rol).

Así, rotar el secreto se propaga en el siguiente arranque, sin recrear la base.
