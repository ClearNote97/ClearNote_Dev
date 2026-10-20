# scripts/ — Scripts de operación

Utilidades operativas del proyecto (arranque, tareas de mantenimiento, configuración de servicios).

- `bootstrap-env.sh` — deja `.env` y el secreto de la DB listos **antes del primer `up`** (nombres derivados de la
  carpeta). Lo llaman el `initializeCommand` del devcontainer e `init.sh`. Idempotente.
- `smoke-test.sh` — ¿está sano el proyecto? Carpeta↔`APP_NAME`, sintaxis, guards de la DB, bootstrap y el
  interruptor de compose. Sin red, no modifica nada. Lo corre `init.sh` al final; a mano: `bash scripts/smoke-test.sh`.
- `nginx/` — configuración de Nginx para el servicio opcional de reverse proxy.
