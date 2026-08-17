"""
MÓDULO: Pipeline de Extracción, Limpieza y Carga (ETL) - Datos de Pozos Master
PROYECTO: SIGATLAS - Tesis de Grado
AUTOR: DERINSON ROJAS
DESCRIPCIÓN: 
    ETL simplificado para pozos_master. 
    Las reglas de negocio (normalización, validaciones, reglas telescópicas, 
    booleanos, estatus, etc.) ahora se ejecutan en PostgreSQL mediante 
    función + trigger. Este script solo limpia datos crudos y carga.
"""

import pandas as pd
from sqlalchemy import create_engine, text
from dotenv import load_dotenv
import os

# ==========================================
# 1. EXTRACCIÓN (Ingesta de datos crudos)
# ==========================================
print(">> Iniciando extracción de datos...")
df = pd.read_csv(
    "pozosMaster.txt", 
    sep=";", 
    encoding="Latin-1",
    na_values=["", " "],
    skipinitialspace=True
)

# ==========================================
# 2. TRANSFORMACIÓN (Limpieza básica y estandarización)
# ==========================================
print(">> Ejecutando transformación básica...")

# 2.1. Estandarización de nombres de columnas
df.columns = df.columns.str.lower()

diccionario_nombres = {
    'iden': 'id_pozo',
    'diam1': 'diametro_superior_in',
    'diam2': 'diametro_inferior_in',
    'pbombeo': 'ind_bombeo',
    'reg': 'ind_registro',
    'epozo': 'cod_estatus_pozo',
    'nivel': 'nivel_estatico_m',
    'nd': 'nivel_dinamico_m',
    'prop': 'propietario',
    'lat': 'latitud',
    'lon': 'longitud',
    'gasto': 'gasto_l_s',
    'perf': 'prof_perforacion_m',
    'norte': 'norte_m',
    'este': 'este_m',
    'cota': 'altitud_msnm',
    'entu': 'prof_entubado_m'
}
df = df.rename(columns=diccionario_nombres)

# 2.2. Conversión de columnas numéricas
columnas_numericas = [
    'latitud', 'longitud', 'prof_perforacion_m', 'gasto_l_s', 'altitud_msnm',
    'prof_entubado_m', 'nivel_estatico_m', 'nivel_dinamico_m',
    'norte_m', 'este_m', 'diametro_superior_in', 'diametro_inferior_in'
]

for col in columnas_numericas:
    if col in df.columns:
        df[col] = pd.to_numeric(df[col], errors='coerce')

# 2.3. Eliminación de duplicados en ID
print(f">> Registros antes de eliminar duplicados: {len(df)}")
df = df.drop_duplicates(subset=['id_pozo'], keep='first')
print(f">> Registros después de eliminar duplicados: {len(df)}")

# 2.4. Columnas legacy como texto
columnas_legacy = ['feniv', 'const']
df[columnas_legacy] = df[columnas_legacy].astype('string')

# 2.5. Estandarización de fechas (solo limpieza básica)
df['act_master'] = pd.to_datetime(df['act_master'], dayfirst=True, errors='coerce').dt.normalize()

# ==========================================
# 3. EXPORTACIÓN A CSV (DATOS_PROCESADOS)
# ==========================================
ruta_salida = os.path.join(
    os.path.dirname(__file__),
    "..", "..",
    "DATOS_PROCESADOS",
    "DATOS_POST_ETL_POZOS_MASTER.csv"
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

# 4.1. Vaciar tabla pero mantener estructura y vistas
with engine.begin() as con:
    print(">> TRUNCATE TABLE pozos_master (manteniendo estructura y vistas)...")
    con.execute(text("TRUNCATE TABLE public.pozos_master;"))

# 4.2. Carga de datos (el trigger aplica reglas de negocio)
print(">> Inyectando datos en pozos_master...")
df.to_sql(
    name="pozos_master",
    con=engine,
    if_exists="append",
    index=False
)

print(">> ETL pozos_master ejecutado con éxito. Lógica de negocio aplicada por trigger.")