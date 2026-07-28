# src/utils/index_management.py
import pandas as pd


def consolidar_ids_unicos(
    dataframes, col_id="ID", return_as="dataframe", set_index=True
):
    """
    Consolida IDs únicos de múltiples DataFrames.

    Parameters
    ----------
    dataframes : list of pd.DataFrame
        Lista de DataFrames a consolidar
    col_id : str, default 'ID'
        Nombre de la columna que contiene el identificador único
    return_as : {'dataframe', 'list', 'set'}, default 'dataframe'
        Formato de salida:
        - 'dataframe': DataFrame con columna de IDs
        - 'list': lista de IDs únicos
        - 'set': conjunto de IDs únicos
    set_index : bool, default True
        Si True y return_as='dataframe', establece col_id como índice

    Returns
    -------
    pd.DataFrame, list, or set
        Según el parámetro return_as

    Examples
    --------
    >>> df_consolidado = consolidar_ids_unicos([df1, df2, df3], col_id='Documento')
    >>> lista_ids = consolidar_ids_unicos([df1, df2], col_id='ID', return_as='list')
    """
    # Validar que hay DataFrames
    if not dataframes or len(dataframes) == 0:
        raise ValueError("La lista de DataFrames está vacía")

    # Consolidar IDs únicos
    unique_ids = set()

    for df in dataframes:
        if col_id not in df.columns:
            raise KeyError(f"La columna '{col_id}' no existe en uno de los DataFrames")
        unique_ids |= set(df[col_id].dropna().unique())

    print(f"✅ Total de IDs únicos consolidados: {len(unique_ids)}")

    # Retornar según formato solicitado
    if return_as == "set":
        return unique_ids

    elif return_as == "list":
        return sorted(list(unique_ids))

    elif return_as == "dataframe":
        df_result = pd.DataFrame(sorted(list(unique_ids)), columns=[col_id])

        if set_index:
            df_result.set_index(col_id, inplace=True)

        return df_result

    else:
        raise ValueError("return_as debe ser 'dataframe', 'list' o 'set'")
