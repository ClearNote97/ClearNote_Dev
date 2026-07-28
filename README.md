# 🐍 Plantilla Dev Container para Data Analysis en Python — ClearNote Py DA

Bienvenido a **ClearNote Py DA**, una plantilla reproducible, ligera y portable para proyectos de análisis de datos en Python usando **Visual Studio Code + Dev Containers + Docker + uv**.

Esta plantilla está pensada para trabajar con un entorno aislado y consistente, sin depender de instalaciones manuales en el sistema anfitrión.

## 🎯 Propósito

Esta plantilla está diseñada para:

- Ejecutar proyectos de análisis de datos **sin instalar dependencias directamente en tu máquina**
- Trabajar con archivos `.py` y `.ipynb` de forma interactiva
- Mantener un entorno reproducible usando **Docker** y **Dev Containers**
- Gestionar dependencias con **uv**, un gestor moderno y rápido para proyectos Python
- Facilitar la transición desde un flujo clásico con `requirements.txt` hacia uno más moderno con `pyproject.toml` + `uv.lock`
- Reducir problemas de permisos en carpetas sincronizadas o montadas desde el host

## 🧱 Estructura del entorno

### Contenedor base

- **Imagen base**: `python:3.14.5-slim-bookworm`
- **Paquetes del sistema**:
  - `build-essential`
  - `ca-certificates`

### Gestión de dependencias

- **Gestor de paquetes/proyectos**: `uv`
- **Versión fijada**: `0.11.13`
- **Instalación de uv**: copiado desde la imagen oficial de Astral
- **Entorno virtual del proyecto**: `.venv/`

### Editor y experiencia de desarrollo

- **Editor principal**: Visual Studio Code
- **Extensiones preconfiguradas**:
  - Python
  - Pylance
  - Ruff
  - Jupyter
  - Better TOML
  - GitHub Copilot
  - Path Intellisense
  - Material Icon Theme

### Intérprete configurado

La plantilla apunta automáticamente al intérprete dentro del entorno virtual:

```bash
${workspaceFolder}/.venv/bin/python
```

## ⚙️ Flujo de inicialización del proyecto

Cuando el contenedor se crea por primera vez, el `postCreateCommand` detecta automáticamente el tipo de proyecto y actúa en consecuencia:

### Caso 1: ya existe `pyproject.toml`

- Si también existe `uv.lock`:
  - ejecuta `uv sync --locked`
- Si no existe `uv.lock`:
  - ejecuta `uv lock && uv sync`

### Caso 2: todavía existe solo `requirements.txt`

- ejecuta `uv init --no-package --no-workspace .`
- elimina el archivo `main.py` generado por defecto
- importa dependencias desde `requirements.txt` con:
  - `uv add -r requirements.txt`

### Caso 3: no existe ninguno

- el proceso falla y muestra un mensaje indicando que falta `pyproject.toml` o `requirements.txt`

## 📂 Filosofía de esta plantilla

Esta plantilla adopta un enfoque de transición en dos etapas:

### Etapa 1: compatibilidad con `requirements.txt`

Ideal para proyectos existentes que todavía no migran por completo a `pyproject.toml`.

Permite:

- seguir usando la estructura tradicional
- empezar a trabajar con `uv`
- crear la base para migrar a lockfiles reproducibles

### Etapa 2: migración total a `pyproject.toml` + `uv.lock`

Recomendada para nuevos proyectos o para consolidar entornos reproducibles.

Ventajas:

- mejor manejo de dependencias
- lockfile reproducible
- flujo más moderno y mantenible
- integración más natural con tooling actual de Python

## 🚀 Instrucciones de uso

### 1. Clona este repositorio

```bash
cd tu_ruta/
git clone https://github.com/ClearNote97/ClearNote_Py_DA.git
cd ClearNote_Py_DA
```

### 2. Desvincula el repositorio original (opcional)

Si quieres usar esta plantilla como base para un proyecto nuevo:

```bash
rm -rf .git
```

Luego renombra la carpeta:

```bash
cd ..
mv ClearNote_Py_DA nuevo_nombre
cd nuevo_nombre
```

Inicializa tu nuevo repositorio:

```bash
git init
git add .
git commit -m "Proyecto inicial basado en plantilla ClearNote Py DA"
```

Y conecta tu propio repositorio si lo deseas:

```bash
git remote add origin https://github.com/tu_usuario/tu_repositorio.git
git push -u origin main
```

### 3. Abre la carpeta en Visual Studio Code

Cuando VS Code detecte la configuración, selecciona:

**Reopen in Container**

### 4. Espera la inicialización automática

Durante la creación del contenedor, la plantilla:

- instala `uv`
- detecta si trabajas con `pyproject.toml` o `requirements.txt`
- prepara el entorno virtual `.venv`
- instala o sincroniza dependencias

No necesitas correr `pip install` manualmente.

## 🧪 ¿Qué puedes hacer aquí?

| Tarea | Disponible ✅ |
|---|---|
| Ejecutar scripts `.py` | ✅ |
| Usar notebooks `.ipynb` | ✅ |
| Ejecutar código por bloques | ✅ |
| Formatear código automáticamente con Ruff | ✅ |
| Organizar imports | ✅ |
| Hacer análisis reproducibles | ✅ |
| Depurar scripts con breakpoints | ✅ |
| Gestionar dependencias con `uv` | ✅ |
| Trabajar dentro de contenedor aislado | ✅ |

## 🛠️ Configuración destacada

### Formato y calidad de código

La plantilla viene preparada para usar **Ruff** como formateador y herramienta de acciones sobre guardado.

### Type checking

Se usa:

```json
"python.analysis.typeCheckingMode": "basic"
```

### Intérprete del proyecto

Se usa automáticamente el Python del entorno virtual `.venv`.

## 📦 Sobre `uv` en esta plantilla

`uv` reemplaza el uso tradicional de `pip` como comando principal del flujo de trabajo.

### ¿Qué aporta?

- mayor velocidad
- manejo moderno de dependencias
- lockfiles reproducibles
- integración con proyectos Python actuales
- mejor experiencia dentro de contenedores reproducibles

### Importante

Aunque la imagen base de Python pueda traer `pip` instalado internamente, esta plantilla **no lo usa como herramienta de trabajo**. Toda la gestión del entorno y dependencias se realiza con `uv`.

## 🧹 Archivos importantes del proyecto

### Deben versionarse

- `README.md`
- `.devcontainer/devcontainer.json`
- `.devcontainer/Dockerfile`
- `requirements.txt` o `pyproject.toml`
- `uv.lock` cuando exista

### No deben versionarse

- `.venv/`
- `__pycache__/`
- `*.pyc`
- `.env`

Un `.gitignore` mínimo recomendado sería:

```gitignore
.env
__pycache__/
*.pyc
.venv/
```

## 🔍 Recomendaciones

- Si vas a mantener esta plantilla como base reproducible, documenta claramente en cada proyecto si estás en modo:
  - `requirements.txt`
  - o `pyproject.toml + uv.lock`
- Si ya migraste a `uv.lock`, consérvalo en el repositorio
- Si usas notebooks o ejecución interactiva, valida que `ipykernel` esté incluido dentro de tus dependencias del proyecto

## ⚖️ Licencia

Distribuido bajo la licencia [MIT](https://opensource.org/license/MIT). Puedes copiar, modificar y reutilizar libremente esta plantilla.

## ✍️ Autor

**MSc. Nicolás Enrique Valencia Santiago**

## 📝 Nota final

Este `README.md` está pensado como base y debe adaptarse según el tipo de proyecto que se construya a partir de esta plantilla.
