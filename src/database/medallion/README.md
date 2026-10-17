# src/database/medallion — Warehouse (arquitectura medallion)

El almacén de datos del proyecto, por capas **bronze → silver → gold**. Es **DDL a mano**
(no modelos SQLModel), así que **el autogenerate de Alembic lo IGNORA** (filtro `include_object`
en `migrations/env.py`) — nunca propone DROP de estas tablas.

> Se llama `medallion`, **no** `analytics`, a propósito: *analytics* es análisis/ML y vive en
> `src/analytics/`. Esto es el **warehouse**, otra cosa.

## Las capas
- **`bronze/`** — aterrizaje crudo, fiel a la fuente; loaders (archivo→bronze) en `bronze/ingest/`.
- **`silver/`** — limpieza y estandarización a conceptos canónicos; SPs inter-capa en `silver/procedures/`.
- **`gold/`** — consumo analítico: `queries/` (OLAP) y `datasets/` (vistas/datasets de `gold`).

## Frontera database ↔ backend
Aquí se **define y transforma el dato** (DDL, SPs, loaders). El **comportamiento** de la app
(servicios, casos de uso, auth, orquestación) va en `src/backend/`.
Regla: *dato en Postgres → `database`; comportamiento → `backend`.*
