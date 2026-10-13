"""
MÓDULO: Pipeline de Extracción, Limpieza y Carga (ETL) - Datos de Pozos Master
PROYECTO: SIGATLAS - Tesis de Grado
AUTOR: DERINSON ROJAS
DESCRIPCIÓN: 
    ETL para pozos_master usando STAGING + VALIDACIÓN + SWAP.
    Sin TRUNCATE. Compatible con PK–FK.
"""

import pandas as pd
from sqlalchemy import create_engine, text
from dotenv import load_dotenv
import os

# ==========================================
# 1. EXTRACCIÓN
# ==========================================
print(">> Iniciando extracción de datos de pozos master limpio...")

ruta_entrada = os.path.join(
    os.path.dirname(__file__),
    "..",
    "POZOS_MASTER",
    "pozosMasterLimpio.txt"
)

df = pd.read_csv(
    ruta_entrada, 
    sep=";", 
    encoding="utf-8",
    na_values=["", " "],
    skipinitialspace=True
)

# ==========================================
# 2. TRANSFORMACIÓN
# ==========================================
print(">> Ejecutando transformación básica...")

df.columns = df.columns.str.lower()

diccionario_nombres = {
    'iden': 'id_pozo',
    'pbombeo': 'ind_bombeo',
    'reg': 'ind_registro',
    'epozo': 'cod_estatus_pozo',
    'prop': 'propietario',
    'lat': 'latitud',
    'lon': 'longitud',
    'norte': 'norte_m',
    'este': 'este_m',
    'cota': 'altitud_msnm'
}
df = df.rename(columns=diccionario_nombres)

columnas_numericas = ['latitud', 'longitud', 'altitud_msnm', 'norte_m', 'este_m']
for col in columnas_numericas:
    if col in df.columns:
        df[col] = pd.to_numeric(df[col], errors='coerce')

print(f">> Registros antes de eliminar duplicados: {len(df)}")
df = df.drop_duplicates(subset=['id_pozo'], keep='first')
print(f">> Registros después de eliminar duplicados: {len(df)}")

columnas_legacy = ['feniv', 'const']
for col in columnas_legacy:
    if col in df.columns:
        df[col] = df[col].astype('string')

if 'act_master' in df.columns:
    df['act_master'] = pd.to_datetime(df['act_master'], dayfirst=True, errors='coerce').dt.normalize()

# ==========================================
# 3. EXPORTACIÓN A CSV
# ==========================================
ruta_salida = os.path.join(
    os.path.dirname(__file__),
    "..", "..",
    "DATOS_PROCESADOS",
    "DATOS_POST_ETL_POZOS_MASTER_LIMPIO.csv"
)

print(">> Exportando archivo CSV procesado...")
df.to_csv(ruta_salida, index=False, encoding="utf-8", sep=";")

# ==========================================
# 4. CARGA PROFESIONAL EN POSTGRESQL (STAGING + SWAP)
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

# 4.1. Crear tabla staging si no existe
with engine.begin() as con:
    print(">> Verificando existencia de tabla staging...")
    con.execute(text("""
        CREATE TABLE IF NOT EXISTS public.pozos_master_stg
        (LIKE public.pozos_master INCLUDING ALL);
    """))

# 4.2. Cargar datos en staging
print(">> Cargando datos en tabla staging pozos_master_stg...")
df.to_sql(
    name="pozos_master_stg",
    con=engine,
    if_exists="replace",   # reemplaza staging, NO producción
    index=False
)

# 4.3. Validaciones en staging
with engine.begin() as con:
    print(">> Validando staging...")

    # PK duplicados
    duplicados = con.execute(text("""
        SELECT id_pozo, COUNT(*) 
        FROM public.pozos_master_stg
        GROUP BY id_pozo
        HAVING COUNT(*) > 1;
    """)).fetchall()

    if duplicados:
        raise Exception(f"ERROR: Existen IDs duplicados en staging: {duplicados}")

# 4.4. Swap atómico
with engine.begin() as con:
    print(">> Ejecutando swap atómico...")
    con.execute(text("ALTER TABLE public.pozos_master RENAME TO pozos_master_old;"))
    con.execute(text("ALTER TABLE public.pozos_master_stg RENAME TO pozos_master;"))

print(">> Swap completado. Verifica integridad antes de borrar pozos_master_old.")

print(">> ETL pozos_master ejecutado con éxito. Sistema actualizado sin TRUNCATE.")
