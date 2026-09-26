"""
MÓDULO: Pipeline de Extracción, Limpieza y Carga (ETL) - Datos Técnicos de Pozos
PROYECTO: SIGATLAS - Tesis de Grado
AUTOR: DERINSON ROJAS
DESCRIPCIÓN: 
    ETL para pozos_datos_tecnicos a partir del archivo pozosDatosTecnicos.txt.
"""

import pandas as pd
from sqlalchemy import create_engine, text
from dotenv import load_dotenv
import os

# ==========================================
# 1. EXTRACCIÓN (Ingesta de datos técnicos crudos)
# ==========================================
print(">> Iniciando extracción de datos técnicos de pozos...")
ruta_entrada = os.path.join(
    os.path.dirname(__file__),
    "..",
    "POZOS_DATOS_TECNICOS",
    "pozosDatosTecnicos.txt"
)

df = pd.read_csv(
    ruta_entrada, 
    sep=";", 
    encoding="utf-8",
    na_values=["", " "],
    skipinitialspace=True
)

# ==========================================
# 2. TRANSFORMACIÓN (Limpieza y estandarización)
# ==========================================
print(">> Ejecutando transformación de datos técnicos...")

# 2.1. Estandarización de nombres de columnas
df.columns = df.columns.str.lower()

diccionario_nombres = {
    'iden': 'id_pozo',
    'perf': 'prof_perforacion_m',
    'entu': 'prof_entubado_m',
    'nivel': 'nivel_estatico_m',
    'nd': 'nivel_dinamico_m',
    'gasto': 'gasto_l_s',
    'diam1': 'diametro_superior_in',
    'diam2': 'diametro_inferior_in'
}
df = df.rename(columns=diccionario_nombres)

# 2.2. Conversión de columnas numéricas
columnas_numericas = [
    'prof_perforacion_m', 'prof_entubado_m', 'nivel_estatico_m', 
    'nivel_dinamico_m', 'gasto_l_s', 'diametro_superior_in', 'diametro_inferior_in'
]

for col in columnas_numericas:
    if col in df.columns:
        df[col] = pd.to_numeric(df[col], errors='coerce')

# 2.3. Eliminación de duplicados en ID
print(f">> Registros antes de eliminar duplicados: {len(df)}")
df = df.drop_duplicates(subset=['id_pozo'], keep='first')
print(f">> Registros después de eliminar duplicados: {len(df)}")

# ==========================================
# 3. EXPORTACIÓN A CSV (DATOS_PROCESADOS)
# ==========================================
ruta_salida = os.path.join(
    os.path.dirname(__file__),
    "..", "..",
    "DATOS_PROCESADOS",
    "DATOS_POST_ETL_POZOS_DATOS_TECNICOS.csv"
)

print(">> Exportando archivo CSV procesado...")
df.to_csv(ruta_salida, index=False, encoding="utf-8", sep=";")

# ==========================================
# 4. CARGA EN POSTGRESQL (TRUNCATE + APPEND)
# ==========================================
print(">> Conectando con PostgreSQL...")
load_dotenv()

USER = os.getenv('DB_USER')
PASSWORD = os.getenv('DB_PASSWORD')
HOST = os.getenv('DB_HOST')
PORT = os.getenv('DB_PORT')
DB_NAME = os.getenv('DB_NAME')

URL_CONEXION = f'postgresql://{USER}:{PASSWORD}@{HOST}:{PORT}/{DB_NAME}'
engine = create_engine(URL_CONEXION)

# 4.1. Vaciar tabla pero mantener estructura
with engine.begin() as con:
    print(">> TRUNCATE TABLE pozos_datos_tecnicos...")
    con.execute(text("TRUNCATE TABLE public.pozos_datos_tecnicos;"))

# 4.2. Carga de datos
print(">> Inyectando datos en pozos_datos_tecnicos...")
df.to_sql(
    name="pozos_datos_tecnicos",
    con=engine,
    if_exists="append",
    index=False
)

print(">> ETL pozos_datos_tecnicos ejecutado con éxito.")