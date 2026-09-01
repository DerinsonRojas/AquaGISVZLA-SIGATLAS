"""
MÓDULO: Pipeline de Extracción, Limpieza y Carga (ETL) - Datos de Pozos Litoología
PROYECTO: SIGATLAS - Tesis de Grado
AUTOR: DERINSON ROJAS
DESCRIPCIÓN: 
    ETL simplificado para pozos_litologia. 
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
    "pozosLitologia.txt", 
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
    'lito': 'litologia',
    'act_litolo':'act_litologia'
    
}
df = df.rename(columns=diccionario_nombres)

# 2.2. Conversión de columnas numéricas
columnas_numericas = [
    'desde', 'hasta'
]

for col in columnas_numericas:
    if col in df.columns:
        df[col] = df[col].astype(str).str.replace(',', '.')
        df[col] = pd.to_numeric(df[col], errors='coerce')


# 2.3. Estandarización de fechas (solo limpieza básica)
df['act_litologia'] = pd.to_datetime(df['act_litologia'], dayfirst=True, errors='coerce').dt.normalize()

# ==========================================
# 3. EXPORTACIÓN A CSV (DATOS_PROCESADOS)
# ==========================================
ruta_salida = os.path.join(
    os.path.dirname(__file__),
    "..", "..",
    "DATOS_PROCESADOS",
    "DATOS_POST_ETL_POZOS_LITOLOGIA.csv"
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
    print(">> TRUNCATE TABLE pozos_litologia (manteniendo estructura y vistas)...")
    con.execute(text("TRUNCATE TABLE public.pozos_litologia;"))

# 4.2. Carga de datos (el trigger aplica reglas de negocio)
print(">> Inyectando datos en pozos_litologia...")
df.to_sql(
    name="pozos_litologia",
    con=engine,
    if_exists="append",
    index=False
)

print(">> ETL pozos_litologia ejecutado con éxito. Lógica de negocio aplicada por trigger.")