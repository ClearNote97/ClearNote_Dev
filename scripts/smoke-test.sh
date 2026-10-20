#!/usr/bin/env bash
# =============================================================================
# smoke-test.sh — ¿Está sano el proyecto? Rápido, sin red, no modifica nada.
# =============================================================================
#   Uso:  bash scripts/smoke-test.sh
#
# Corre en el host o dentro del devcontainer (donde no hay Docker CLI, los chequeos
# de compose se omiten). Lo invoca init.sh al final (sin bloquear) y es parte del
# ritual de arranque (README_AGENTS §3). Nada está atado al nombre de la plantilla:
# todo se deriva de la carpeta donde vive el proyecto.
#
# Salida: ✅ ok · ⚠️ aviso (no falla) · ❌ falla (exit 1).
# =============================================================================
set -uo pipefail
cd "$(dirname "$0")/.."

pass=0; warn=0; fail=0
ok() { echo "  ✅ $*"; pass=$((pass + 1)); }
wa() { echo "  ⚠️  $*"; warn=$((warn + 1)); }
ko() { echo "  ❌ $*"; fail=$((fail + 1)); }
env_get() { grep -E "^$1=" "$2" 2>/dev/null | cut -d= -f2- | sed 's/#.*//' | tr -d '[:space:]'; }

PY="$(command -v python3 || command -v python || true)"
folder="$(basename "$PWD")"
in_container=false; [ -f /.dockerenv ] && in_container=true

echo "▶ smoke-test — $folder"

# --- 1. Carpeta ↔ APP_NAME ----------------------------------------------------
# Si se renombra la carpeta, el mount (/workspaces/${APP_NAME}) y el workspace
# (/workspaces/<carpeta>) divergen y el contenedor abre una carpeta vacía.
echo "· Identidad"
if [ -f .env ]; then
  app="$(env_get APP_NAME .env)"
  if [ "$app" = "$folder" ] || $in_container; then
    ok "APP_NAME coincide con la carpeta ($folder)"
  else
    wa "APP_NAME='$app' ≠ carpeta '$folder' (¿renombraste la carpeta?) → bash scripts/bootstrap-env.sh y reconstruye el contenedor"
  fi
  dbn="$(env_get DB_NAME .env)"; dbu="$(env_get DB_USER .env)"
  if [ "$dbn" = "db_nombre_proyecto" ] || [ "$dbu" = "admin_proyecto" ]; then
    wa "DB_NAME/DB_USER siguen en placeholder → bash scripts/bootstrap-env.sh (antes del primer up)"
  fi
else
  wa ".env aún no existe → bash scripts/bootstrap-env.sh"
fi

# --- 2. Sintaxis ----------------------------------------------------------------
echo "· Sintaxis"
bad=0
for f in init.sh scripts/*.sh src/database/admin/run-admin.sh; do
  [ -f "$f" ] || continue
  bash -n "$f" 2>/dev/null || { ko "bash: $f"; bad=1; }
done
[ "$bad" = 0 ] && ok "scripts bash"

if [ -n "$PY" ]; then
  # ast.parse no escribe __pycache__ (py_compile sí).
  if out="$(find src -name '*.py' -print0 | xargs -0 "$PY" -I -c '
import ast, sys
for f in sys.argv[1:]:
    try:
        ast.parse(open(f, encoding="utf-8").read(), f)
    except SyntaxError as e:
        print(f"{f}:{e.lineno}: {e.msg}")
' 2>&1)" && [ -z "$out" ]; then
    ok "código Python (src/)"
  else
    ko "Python con errores de sintaxis:"; echo "$out" | sed 's/^/       /'
  fi
else
  wa "sin intérprete Python → se omite la sintaxis de src/"
fi

# --- 3. Guards de la DB (sin importar los módulos) ----------------------------
# include_object (autogenerate no toca el medallion) y set_local_role (SET LOCAL
# ROLE, no SET ROLE). Se extraen con ast para no disparar migraciones ni conexión.
echo "· Guards de la base de datos"
if [ -n "$PY" ] && [ -f src/database/migrations/env.py ] && [ -f src/database/session.py ]; then
  if out="$("$PY" -I - <<'PY' 2>&1
import __future__, ast

def load(path, names):
    tree = ast.parse(open(path, encoding="utf-8").read())
    keep = [n for n in tree.body
            if (isinstance(n, ast.FunctionDef) and n.name in names)
            or (isinstance(n, ast.Assign) and any(getattr(t, "id", None) in names for t in n.targets))]
    ns = {}
    # Las funciones usan `from __future__ import annotations`: compilarlas igual.
    code = compile(ast.Module(body=keep, type_ignores=[]), path, "exec",
                   flags=__future__.annotations.compiler_flag, dont_inherit=True)
    exec(code, ns)
    return ns

class Obj:
    def __init__(self, schema):
        self.schema = schema

f = load("src/database/migrations/env.py", {"_include_object", "MANAGED_SCHEMAS"})["_include_object"]
assert f(Obj("app"), "t", "table", False, None) is True, "debe incluir el schema app"
assert f(Obj(None), "t", "table", False, None) is True, "debe incluir tablas sin schema"
assert f(Obj("bronze"), "t", "table", True, None) is False, "debe EXCLUIR bronze (si no, propone DROP)"
assert f(Obj("gold"), "c", "column", True, None) is False, "debe EXCLUIR columnas de gold"

ns = load("src/database/session.py", {"set_local_role"})
ns["text"] = lambda q: q
calls = []
class Sess:
    def execute(self, q):
        calls.append(q)
ns["set_local_role"](Sess(), "data_owner")
assert calls[-1] == 'SET LOCAL ROLE "data_owner"', calls[-1]
ns["set_local_role"](Sess(), 'x"y')
assert calls[-1] == 'SET LOCAL ROLE "x""y"', "el nombre del rol debe ir citado"
PY
  )"; then
    ok "include_object protege el medallion · set_local_role usa SET LOCAL y cita el rol"
  else
    ko "guard de DB roto:"; echo "$out" | tail -1 | sed 's/^/       /'
  fi
else
  wa "sin capa de DB o sin Python → se omiten los guards"
fi

# --- 4. bootstrap-env en una carpeta temporal -------------------------------
echo "· Bootstrap"
if command -v openssl >/dev/null 2>&1 && [ -f scripts/bootstrap-env.sh ] && [ -f .env.example ]; then
  tmp="$(mktemp -d)"; proj="$tmp/Smoke_Proyecto"
  mkdir -p "$proj/scripts"
  cp scripts/bootstrap-env.sh "$proj/scripts/"; cp .env.example "$proj/"
  if (cd "$proj" && bash scripts/bootstrap-env.sh >/dev/null 2>&1) \
     && [ "$(env_get APP_NAME "$proj/.env")" = "Smoke_Proyecto" ] \
     && [ "$(env_get DB_NAME "$proj/.env")" = "smoke_proyecto_db" ] \
     && [ "$(env_get DB_USER "$proj/.env")" = "smoke_proyecto_admin" ] \
     && [ -s "$proj/secrets/db_password.txt" ] \
     && ! grep -qE '^(APP_NAME|DB_NAME|DB_USER)=.*[[:space:]]$' "$proj/.env"; then
    ok "bootstrap-env deriva nombres de la carpeta y genera el secreto"
  else
    ko "bootstrap-env no dejó .env/secreto como se espera"
  fi
  rm -rf "$tmp"
else
  wa "sin openssl o sin bootstrap-env.sh → se omite"
fi

# --- 5. compose: el interruptor de DB (COMPOSE_PROFILES) ----------------------
echo "· Compose"
if ! $in_container && command -v docker >/dev/null 2>&1 && [ -f docker-compose.yml ]; then
  tmp="$(mktemp -d)"
  sed 's/^COMPOSE_PROFILES=.*/COMPOSE_PROFILES=/'   .env.example > "$tmp/off.env"
  sed 's/^COMPOSE_PROFILES=.*/COMPOSE_PROFILES=db/' .env.example > "$tmp/on.env"
  off="$(env -u COMPOSE_PROFILES docker compose --env-file "$tmp/off.env" config --services 2>/dev/null | tr '\n' ' ')"
  on="$(env -u COMPOSE_PROFILES docker compose --env-file "$tmp/on.env"  config --services 2>/dev/null | tr '\n' ' ')"
  rm -rf "$tmp"
  if [[ " $off " == *" app-dev "* && " $off " != *" db "* ]]; then ok "sin DB: solo app-dev"; else ko "sin DB: servicios inesperados [$off]"; fi
  if [[ " $on " == *" db "* && " $on " == *" app-dev "* ]]; then ok "con DB: db + app-dev"; else ko "con DB: servicios inesperados [$on]"; fi
else
  wa "sin Docker CLI (p. ej. dentro del contenedor) → se omite compose"
fi

# --- Resumen ----------------------------------------------------------------
echo "▶ $pass ok · $warn avisos · $fail fallas"
[ "$fail" -eq 0 ]
