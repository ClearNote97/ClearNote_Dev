#!/usr/bin/env bash
# =============================================================================
# bootstrap-env.sh — Deja .env + el secreto de la DB LISTOS antes del primer `up`.
# =============================================================================
# Lo llaman el `initializeCommand` del devcontainer (host, antes de levantar) e
# `init.sh` (modo host). Idempotente. Requiere bash + openssl.
#
# Por qué existe: Postgres solo honra POSTGRES_DB/USER en la PRIMERA init del
# volumen, y eso es irreversible sin recrearlo. Si en ese primer `up` el `.env`
# aún trae los placeholders de DB, la base nace mal nombrada. Este script fija
# los nombres del proyecto ANTES de que compose levante nada.
# =============================================================================
set -euo pipefail
cd "$(dirname "$0")/.."   # raíz del proyecto (scripts/ cuelga de la raíz)

# .env desde el ejemplo si falta.
[ -f .env ] || cp .env.example .env

# Setter idempotente: reemplaza SOLO el valor (preserva el comentario inline) y no
# deja espacios colgando. Si la clave no existe, la agrega.
set_env() {
  local key="$1" val="$2"
  if grep -qE "^${key}=" .env; then
    sed -i -E "s|^(${key}=)[^[:space:]#]*|\1${val}|" .env
  else
    printf '%s=%s\n' "$key" "$val" >> .env
  fi
}

# APP_NAME = nombre de la carpeta (el mount ${APP_NAME} y el workspace nunca divergen).
folder="$(basename "$PWD")"
set_env APP_NAME "$folder"

# DB_NAME/DB_USER: si siguen en placeholder, derivar un slug del folder
# (identificadores Postgres en minúsculas). Nunca pisa valores que ya fijó el usuario.
slug="$(printf '%s' "$folder" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '_' | sed -E 's/^_+|_+$//g')"
if grep -qE '^DB_NAME=db_nombre_proyecto' .env; then set_env DB_NAME "${slug}_db"; fi
if grep -qE '^DB_USER=admin_proyecto'     .env; then set_env DB_USER "${slug}_admin"; fi

# Secreto de la DB (docker-compose lo monta como bind; falla si el archivo no existe).
mkdir -p secrets
[ -s secrets/db_password.txt ] || openssl rand -base64 24 > secrets/db_password.txt

echo "✅ bootstrap-env: .env listo (APP_NAME=$folder) y secreto de DB presente."
