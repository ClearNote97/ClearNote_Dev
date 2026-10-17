# medallion/bronze — Aterrizaje crudo

Datos tal como llegan de la fuente, sin transformar (fidelidad > comodidad).

- **`ingest/`** — loaders (archivo→bronze), "SP de etapa 0" en Python. *(Créalo al ingerir.)*
- Fuente con **esquema estable** → tabla de columnas tipadas.
- Fuente cuyo **esquema driftea** → una columna `fila jsonb` con la fila cruda completa
  (cero pérdida, a prueba de columnas nuevas). La estandarización se hace en `silver/`.

> **Antes de dar una fuente por "lista", corre un piloto con un archivo REAL** (no solo mocks):
> destapa manifiestos, hojas mal autodetectadas y cargas "exitosas" con 0 columnas mapeadas
> (bandera roja: un `try/catch` verde no basta — mira la cobertura).
