"""
Módulo para limpieza de espacios en blanco en DataFrames.
Primer paso del flujo de procesamiento de datos.
"""

"""
Limpieza de espacios en blanco en DataFrames.
"""
import re
import numpy as np


def limpiar_espacios_en_blanco(df):
    df = df.copy()  # Crear una copia para no modificar el original directamente

    # Limpiar espacios en blanco en los nombres de las columnas
    df.columns = [
        col.strip() if isinstance(col, str) else "" if col is None else col
        for col in df.columns
    ]

    # 🔧 CORREGIDO: usar re.sub() en lugar de .replace() con regex
    df.columns = [
        re.sub(r"^\s+|\s+$", "", col) if isinstance(col, str) else col
        for col in df.columns
    ]

    # Reemplazar múltiples espacios/saltos de línea internos por un solo espacio
    df.columns = [
        re.sub(r"\s+", " ", col) if isinstance(col, str) else col for col in df.columns
    ]

    # Eliminar espacios al inicio y final en todos los valores del DataFrame (celdas)
    df = df.replace(r"^\s+|\s+$", "", regex=True)

    # Reemplazar múltiples espacios internos por un solo espacio
    df = df.replace(r"\s+", " ", regex=True)

    # Reemplazar cadenas vacías por NaN para facilitar manejo de datos faltantes
    df = df.replace("", np.nan)

    # Eliminar filas que estén completamente vacías (todos los valores NaN)
    df = df.dropna(how="all")

    return df
