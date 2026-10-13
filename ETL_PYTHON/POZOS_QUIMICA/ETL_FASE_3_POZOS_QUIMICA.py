"""
ETL para pozos_quimica usando STAGING + VALIDACIÓN + SWAP.
Compatible con PK–FK.
"""

import os
import pandas as pd
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

# ==========================================
# 1. EXTRACCIÓN
# ==========================================
print(">> Iniciando extracción de datos de química...")
df = pd.read_csv(
    "pozosQuimica.txt", 
    sep=";", 
    encoding="Latin-1",
    na_values=["", " "],
    skipinitialspace=True,
    quotechar='"'
)

# ==========================================
# 2. TRANSFORMACIÓN
# ==========================================
print(">> Ejecutando transformación básica...")

df.columns = df.columns.str.lower()

df = df.rename(columns={
    'iden': 'id_pozo',
    'temp': 'temperatura_c',
    'conduc':'conductividad_us_cm'
})

df['id_pozo'] = df['id_pozo'].astype(str).str.strip()

columnas_numericas = [
    'temperatura_c','ph','indice','conductividad_us_cm','alc','dtotal','tsd','ras','cl','so4',
    'f','no2','no3','sio2','hco3','co3','fe','mn','b','duca','ca','mg','na','k',
    'cu','zn','pb','po4'
]

for col in columnas_numericas:
    if col in df.columns:
        df[col] = df[col].astype(str).str.replace(',', '.', regex=False)
        df[col] = pd.to_numeric(df[col], errors='coerce')

if 'act_quimi' in df.columns:
    df['act_quimi'] = pd.to_datetime(df['act_quimi'], dayfirst=True, errors='coerce').dt.normalize()

# ==========================================
# 3. EXPORTACIÓN A CSV
# ==========================================
ruta_salida = os.path.join(
    os.path.dirname(__file__), "..","..",
    "DATOS_PROCESADOS", 
    "DATOS_POST_ETL_POZOS_QUIMICA.csv"
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

engine = create_engine(f'postgresql://{USER}:{PASSWORD}@{HOST}:{PORT}/{DB_NAME}')

# 4.1. Crear tabla staging si no existe
with engine.begin() as con:
    print(">> Verificando existencia de tabla staging...")
    con.execute(text("""
        CREATE TABLE IF NOT EXISTS public.pozos_quimica_stg
        (LIKE public.pozos_quimica INCLUDING ALL);
    """))

# 4.2. Validación estricta de FK contra pozos_master
print(">> Validando integridad referencial con pozos_master...")
df_master = pd.read_sql("SELECT id_pozo FROM public.pozos_master;", con=engine)
ids_validos = set(df_master['id_pozo'].astype(str).str.strip())

df = df[df['id_pozo'].isin(ids_validos)].copy()

# 4.3. Cargar staging
print(">> Cargando datos en tabla staging pozos_quimica_stg...")
df.to_sql(
    name="pozos_quimica_stg",
    con=engine,
    if_exists="replace",
    index=False
)

# 4.4. Validaciones en staging
with engine.begin() as con:
    print(">> Validando staging...")

    duplicados = con.execute(text("""
        SELECT id_pozo, COUNT(*)
        FROM public.pozos_quimica_stg
        GROUP BY id_pozo
        HAVING COUNT(*) > 1;
    """)).fetchall()

    if duplicados:
        raise Exception(f"ERROR: Existen registros duplicados en química: {duplicados}")

# 4.5. Swap atómico
with engine.begin() as con:
    print(">> Ejecutando swap atómico...")
    con.execute(text("ALTER TABLE public.pozos_quimica RENAME TO pozos_quimica_old;"))
    con.execute(text("ALTER TABLE public.pozos_quimica_stg RENAME TO pozos_quimica;"))

print(">> Swap completado. Verifica integridad antes de borrar pozos_quimica_old.")
print(">> ETL pozos_quimica ejecutado con éxito sin TRUNCATE.")
