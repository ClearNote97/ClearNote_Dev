# 🏛️ ClearNote_Dev — Plantilla para desarrollo de aplicaciones (Spec-Driven)

Plantilla **insignia** para construir **aplicaciones full-stack en Python** de forma reproducible y portable
(**VS Code + Dev Containers + Docker + `uv`**), siguiendo **Spec-Driven Development (SDD)**: el diseño y la
documentación guían el código, no al revés.

> **¿Cómo se colabora con un agente de IA en este repo?** Eso vive en el contrato **`README_AGENTS.md`**
> (agnóstico de herramienta). Este archivo es *qué es el proyecto y cómo está organizado*.

> ⚠️ **En construcción:** este README documenta hoy la **metodología** y la **estructura**. Las secciones de
> *instalación* y *especificaciones técnicas* (stack, PostgreSQL, `docker-compose`) se completan tras cerrar el stack.

---

## 🧭 Filosofía: Spec-Driven Development

**Invariante raíz:** el *spec* es la **fuente de verdad**; el código es su **implementación**. Nada se construye
sin spec; nada está "hecho" hasta que cumple su spec y pasa sus criterios de aceptación. El flujo es
**unidireccional hacia abajo** — si algo cambia, entra por el spec.

**Los 5 niveles** (cada uno con su *gate* de aprobación antes de bajar al siguiente):

| # | Nivel | Responde | Vive en |
|---|---|---|---|
| 1 | **Constitución** | ¿quiénes somos, qué no se negocia? | `spec/constitution/` |
| 2 | **Especificación** | el **QUÉ** y el **PORQUÉ** (criterios de aceptación) | `spec/features/` |
| 3 | **Plan** | el **CÓMO** (arquitectura, modelo de datos, contratos) | `spec/` |
| 4 | **Tareas** | descomposición accionable y testeable | `spec/features/NNN/` |
| 5 | **Implementación** | construir + **verificar contra el spec** | `src/` + `tests/` |

**`spec/` vs `docs/`** — la distinción clave:

- **`spec/` = lo que DEBE ser verdad** (prescriptivo, precede al código; el **código** se verifica contra él).
- **`docs/` = cómo y por qué es así** (descriptivo, narra lo construido; los **docs** se corrigen contra la realidad).
- Si `spec ≠ código` → el código está mal. Si `docs ≠ realidad` → los docs están mal.

---

## 📂 Estructura del proyecto

```
ClearNote_Dev/
├── spec/                        # 📜 lo que DEBE ser verdad (prescriptivo)
│   ├── constitution/            #   Nivel 1 — la capa que gobierna todo
│   │   ├── 00_purpose.md        #     por qué existe (misión + problema + para quién)
│   │   ├── 01_principles.md     #     lo NO-negociable (spec-first, test-first, repro, seguridad…)
│   │   ├── 02_scope.md          #     qué está dentro y qué NO
│   │   └── 03_stack.md          #     fundación técnica y restricciones
│   ├── roadmap.md               #   hacia dónde va (planificación viva)
│   ├── contracts/               #   contratos TRANSVERSALES del sistema (OpenAPI, esquemas compartidos)
│   └── features/                #   Niveles 2-4 — una carpeta por feature
│       └── NNN_nombre/
│           ├── spec.md          #     Nivel 2 — el QUÉ + criterios de aceptación
│           ├── plan.md          #     Nivel 3 — el CÓMO
│           └── tasks.md         #     Nivel 4 — descomposición
│
├── docs/                        # 📖 cómo y por qué es así (descriptivo)
│   ├── architecture/            #   el sistema ensamblado, narrado (incluye doc del esquema DB)
│   ├── decisions/               #   ADRs (un archivo por decisión) + maestro consolidado a futuro
│   ├── business/                #   dominio: glosario, reglas de negocio explicadas
│   ├── audit/                   #   revisiones de seguridad/dependencias, cumplimiento
│   └── data-dictionary/         #   índice maestro + 1 archivo por tabla (subcarpeta por schema)
│
├── src/                         # ⚙️ Nivel 5 — implementación (cumple el spec)
│   ├── backend/                 #   api (entrada) · schemas (DTOs) · use_cases (operación de negocio) · services (reutilizable)
│   ├── database/                #   admin (gobernanza SQL) · app/{models,repositories} · analytics · migrations · session
│   ├── frontend/                #   views · components · state · layout · services · visuals
│   ├── analytics/               #   ml · statistics · tracking
│   └── utils/                   #   helpers genéricos y portables
│
└── tests/                       # ✅ verifica el spec
    ├── backend/ … database/ … frontend/ … analytics/ … utils/   (unit — espejo de src/)
    └── acceptance/              #   "prueba de fuego" por feature (traza a spec/features/NNN)
```

### La lógica en una frase

**Constitución** gobierna → **Spec** define el *qué* → **Plan** el *cómo* → **Tareas** descomponen →
**`src/`** implementa → **`tests/`** verifica contra los criterios → **`docs/`** explica lo construido.

### Un patrón que se repite: *granular + maestro*

Todo lo que crece en cantidad usa la misma forma: **muchos archivos pequeños y enfocados + un maestro que los
indexa**. Aplica a las **decisiones** (ADRs + maestro) y a los **diccionarios de datos** (uno por tabla + índice maestro).

### Arquitectura limpia (el viaje de una petición)

```
Frontend → api/ → schemas/ → use_cases/ → repositories/ → models/ + DB
            (entrada) (valida)  (orquesta)   (persiste)     (tablas)
                                    ↑
                               services/  (lógica reutilizable propia de la app)
```

Las **reglas de negocio** se aplican en 3 capas: el **modelo** (reglas de forma de un registro) → los
**`use_cases`/`services`** (reglas reales, de proceso) → la **DB** (`CHECK`/RLS/triggers, como red de seguridad).

---

## ⚖️ Licencia

Distribuido bajo licencia [MIT](https://opensource.org/license/MIT).

## ✍️ Autor

**MSc. Nicolás Enrique Valencia Santiago**
