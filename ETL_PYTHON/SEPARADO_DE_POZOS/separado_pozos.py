"""Script para separar el archivo principal de pozosMaster.TXT OBTENIDO DE LA DATA LEGACY, en dos archivos independientes para poder realizar 
la tabla pozos_datos_tecnicos completamente individual de pozos_mastes"""

import pandas as pd
import os

# 1. Cargar el archivo original 
print(">> Iniciando extracción de datos...")
df = pd.read_csv(
    "pozosMaster.txt", 
    sep=";", 
    encoding="Latin-1",
    na_values=["", " "],
    skipinitialspace=True
)


# 2. Crear el DataFrame para datos técnicos (incluyendo IDEN como llave)
ruta_salida_1 = os.path.join(
    os.path.dirname(__file__),
    "..",
    "POZOS_DATOS_TECNICOS",
    "pozosDatosTecnicos.txt"
)
print(">> Exportando archivo TXT procesado...")
cols_tecnicas = ["IDEN", "PERF", "ENTU", "NIVEL", "ND", "GASTO", "DIAM1", "DIAM2"]
df_tecnicos = df[cols_tecnicas]
df_tecnicos.to_csv(ruta_salida_1, sep=";", index=False)


# 3. Crear el DataFrame para el master (eliminando las columnas técnicas que ya sacamos)
ruta_salida_2 = os.path.join(
    os.path.dirname(__file__),
    "..",
    "POZOS_MASTER",
    "pozosMasterLimpio.txt"
)
print(">> Exportando archivo TXT procesado...")
cols_a_remover = ["PERF", "ENTU", "NIVEL", "ND", "GASTO", "DIAM1", "DIAM2"]
df_master = df.drop(columns=cols_a_remover)
df_master.to_csv(ruta_salida_2, sep=";", index=False)




print("¡Archivos separados y listos para la base de datos!")