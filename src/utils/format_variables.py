"""
Módulo para cambio de formatos de variables clave.
Convierte tipos de datos según requerimientos del análisis.
"""

"""
Conversión de formatos de variables (fechas, floats, etc).
"""
import numpy as np
import pandas as pd


# # Formatear columnas específicas como formato adecuado
# Formato de Fechas
def format_dates(df, columns, date_format=None, timestamp_unit=None):
    """
    Convierte columnas a datetime detectando el tipo de dato y reportando errores para corrección manual.

    Parámetros:
    - df: DataFrame
    - columns: lista de columnas a convertir
    - date_format: formato de fecha para strings (opcional)
    - timestamp_unit: si la columna es numérica, puede ser:
        * 'ms' para milisegundos Unix timestamp
        * 's' para segundos Unix timestamp
        * 'excel' para números estilo Excel (días desde 1899-12-30)
        * None para inferir automáticamente

    Retorna:
    - df con columnas convertidas a datetime cuando es posible
    """
    for col in columns:
        if col in df.columns:
            try:
                if pd.api.types.is_numeric_dtype(df[col]):
                    # Columna numérica: interpretar según timestamp_unit
                    if timestamp_unit == "ms":
                        df[col] = pd.to_datetime(df[col], unit="ms", errors="raise")
                    elif timestamp_unit == "s":
                        df[col] = pd.to_datetime(df[col], unit="s", errors="raise")
                    elif timestamp_unit == "excel":
                        df[col] = pd.to_datetime("1899-12-30") + pd.to_timedelta(
                            df[col], unit="D"
                        )
                    else:
                        # Inferir unidad según valor máximo
                        max_val = df[col].max()
                        if max_val > 1e12:
                            df[col] = pd.to_datetime(df[col], unit="ms", errors="raise")
                        else:
                            df[col] = pd.to_datetime(df[col], unit="s", errors="raise")
                else:
                    # Columna no numérica: convertir a string y parsear
                    df[col] = df[col].astype(str).str.split().str[0]
                    if date_format:
                        df[col] = pd.to_datetime(
                            df[col], format=date_format, errors="raise"
                        )
                    else:
                        df[col] = pd.to_datetime(df[col], errors="raise")
            except Exception as e:
                print(f"Error formateando columna {col}: {e}")
                # Mostrar valores problemáticos para corrección manual
                invalid_mask = (
                    ~df[col].apply(lambda x: pd.to_datetime(x, errors="coerce")).notna()
                )
                print(f"Valores problemáticos en columna {col}:")
                print(df.loc[invalid_mask, col].unique())
                # No modificar la columna para que puedas corregir manualmente
    return df


# # Fromato de números
# Enteros
def format_int(df, columns):
    for col in columns:
        if col in df.columns:
            try:
                # Asignar la conversión para modificar el DataFrame
                df[col] = df[col].astype("int64")
            except Exception as e:
                print(f"Error formateando columna {col}: {e}")
    return df


# Flotantes - Decimales
def format_flt(df, columns):
    for col in columns:
        if col in df.columns:
            try:
                # Asignar la conversión para modificar el DataFrame
                df[col] = df[col].astype("float64")
            except Exception as e:
                print(f"Error formateando columna {col}: {e}")
    return df
