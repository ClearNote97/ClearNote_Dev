"""Engine y sesiones de base de datos (SQLModel + SQLAlchemy 2).

Fuente única de la conexión para la aplicación (los endpoints/servicios piden
sesiones aquí). La **resolución de la URL** (APP_ENV, secretos, dev/prod) vive en
`connection.py` — este módulo solo crea el engine y entrega sesiones, para que la
app y Alembic (`migrations/env.py`) compartan exactamente la misma lógica.
"""

from __future__ import annotations

import os
from collections.abc import Iterator

from sqlalchemy import create_engine, text
from sqlmodel import Session

from .connection import build_database_url

# --- Engine: un único pool de conexiones para todo el proceso ---------------
# `pool_pre_ping` evita usar conexiones muertas (típico tras reinicios del contenedor).
# `echo` se controla por entorno para depurar SQL sin tocar el código.
# La URL la resuelve connection.build_database_url() (gira sobre APP_ENV).
engine = create_engine(
    build_database_url(),
    pool_pre_ping=True,
    echo=os.getenv("SQL_ECHO", "").lower() in {"1", "true", "yes"},
)


def get_session() -> Iterator[Session]:
    """Dependencia estilo FastAPI: entrega una sesión y garantiza su cierre.

    Uso:
        @app.get("/items")
        def listar(session: Session = Depends(get_session)):
            ...
    """
    with Session(engine) as session:
        yield session


def set_local_role(session: Session, role: str) -> None:
    """Asume `role` para el RESTO de la transacción actual (se resetea al commit/rollback).

    Llámalo como PRIMER statement de la transacción en cada punto de escritura que deba
    correr como el **dueño de los datos** (p. ej. `data_owner`) — típico al escribir en el
    medallion bajo gobernanza.

    ⚠️ Usa `SET LOCAL ROLE`, **no** `SET ROLE`. Con un pool de conexiones, `SET ROLE` normal
    queda **pegado** en la conexión física cuando vuelve al pool → la siguiente operación
    hereda el rol sin querer. `SET LOCAL` se limita a la transacción y se resetea al cerrarla.

    Ejemplo:
        with Session(engine) as s:
            set_local_role(s, "data_owner")
            s.exec(...)      # corre como data_owner
            s.commit()       # aquí el rol vuelve al usuario base de la conexión
    """
    safe = '"' + role.replace('"', '""') + '"'  # identificador Postgres citado
    session.execute(text(f"SET LOCAL ROLE {safe}"))
