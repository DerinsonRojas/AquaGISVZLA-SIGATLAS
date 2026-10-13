"""
MÓDULO: Pipeline de Extracción, Limpieza y Carga (ETL) - Datos de Pozos Litología
PROYECTO: SIGATLAS - Tesis de Grado
AUTOR: DERINSON ROJAS
DESCRIPCIÓN: 
    ETL para pozos_litologia usando STAGING + VALIDACIÓN + SWAP.
    Sin TRUNCATE. Compatible con PK–FK.
"""

import pandas as pd
from sqlalchemy import create_engine, text
from dotenv import load_dotenv
import os

# ==========================================
# 1. EXTRACCIÓN
# ==========================================
print(">> Iniciando extracción de datos de litología...")

df = pd.read_csv(
    "pozosLitologia.txt", 
    sep=";", 
    encoding="Latin-1",
    na_values=["", " "],
    skipinitialspace=True
)

# ==========================================
# 2. TRANSFORMACIÓN
# ==========================================
print(">> Ejecutando transformación básica...")

df.columns = df.columns.str.lower()

df = df.rename(columns={
    'iden': 'id_pozo',
    'lito': 'litologia',
    'act_litolo': 'act_litologia'
})

columnas_numericas = ['desde', 'hasta']
for col in columnas_numericas:
    if col in df.columns:
        df[col] = df[col].astype(str).str.replace(',', '.')
        df[col] = pd.to_numeric(df[col], errors='coerce')

df['act_litologia'] = pd.to_datetime(df['act_litologia'], dayfirst=True, errors='coerce').dt.normalize()

# ==========================================
# 3. EXPORTACIÓN A CSV
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
        CREATE TABLE IF NOT EXISTS public.pozos_litologia_stg
        (LIKE public.pozos_litologia INCLUDING ALL);
    """))

# 4.2. Validación estricta de FK contra pozos_master
print(">> Validando integridad referencial con pozos_master...")
df_master = pd.read_sql("SELECT id_pozo FROM public.pozos_master;", con=engine)
ids_validos = set(df_master['id_pozo'].astype(str).str.strip())

df = df[df['id_pozo'].isin(ids_validos)].copy()

# 4.3. Cargar staging
print(">> Cargando datos en tabla staging pozos_litologia_stg...")
df.to_sql(
    name="pozos_litologia_stg",
    con=engine,
    if_exists="replace",
    index=False
)

# 4.4. Validaciones en staging
with engine.begin() as con:
    print(">> Validando staging...")

    duplicados = con.execute(text("""
        SELECT id_pozo, desde, hasta, COUNT(*)
        FROM public.pozos_litologia_stg
        GROUP BY id_pozo, desde, hasta
        HAVING COUNT(*) > 1;
    """)).fetchall()

    if duplicados:
        raise Exception(f"ERROR: Existen registros duplicados en litología: {duplicados}")

# 4.5. Swap atómico
with engine.begin() as con:
    print(">> Ejecutando swap atómico...")
    con.execute(text("ALTER TABLE public.pozos_litologia RENAME TO pozos_litologia_old;"))
    con.execute(text("ALTER TABLE public.pozos_litologia_stg RENAME TO pozos_litologia;"))

print(">> Swap completado. Verifica integridad antes de borrar pozos_litologia_old.")
print(">> ETL pozos_litologia ejecutado con éxito sin TRUNCATE.")
