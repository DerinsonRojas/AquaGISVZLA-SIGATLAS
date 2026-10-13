"""
MÓDULO: Pipeline de Extracción, Limpieza y Carga (ETL) - Datos Técnicos de Pozos
PROYECTO: SIGATLAS - Tesis de Grado
AUTOR: DERINSON ROJAS
DESCRIPCIÓN: 
    ETL para pozos_datos_tecnicos usando STAGING + VALIDACIÓN + SWAP.
    Sin TRUNCATE. Compatible con PK–FK.
"""

import pandas as pd
from sqlalchemy import create_engine, text
from dotenv import load_dotenv
import os

# ==========================================
# 1. EXTRACCIÓN
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
# 2. TRANSFORMACIÓN
# ==========================================
print(">> Ejecutando transformación de datos técnicos...")

df.columns = df.columns.str.lower()

df = df.rename(columns={
    'iden': 'id_pozo',
    'perf': 'prof_perforacion_m',
    'entu': 'prof_entubado_m',
    'nivel': 'nivel_estatico_m',
    'nd': 'nivel_dinamico_m',
    'gasto': 'gasto_l_s',
    'diam1': 'diametro_superior_in',
    'diam2': 'diametro_inferior_in'
})

columnas_numericas = [
    'prof_perforacion_m', 'prof_entubado_m', 'nivel_estatico_m', 
    'nivel_dinamico_m', 'gasto_l_s', 'diametro_superior_in', 'diametro_inferior_in'
]

for col in columnas_numericas:
    if col in df.columns:
        df[col] = pd.to_numeric(df[col], errors='coerce')

print(f">> Registros antes de eliminar duplicados: {len(df)}")
df = df.drop_duplicates(subset=['id_pozo'], keep='first')
print(f">> Registros después de eliminar duplicados: {len(df)}")

# ==========================================
# 3. EXPORTACIÓN A CSV
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
        CREATE TABLE IF NOT EXISTS public.pozos_datos_tecnicos_stg
        (LIKE public.pozos_datos_tecnicos INCLUDING ALL);
    """))

# 4.2. Validación estricta de FK contra pozos_master
print(">> Validando integridad referencial con pozos_master...")
df_master = pd.read_sql("SELECT id_pozo FROM public.pozos_master;", con=engine)
ids_validos = set(df_master['id_pozo'].astype(str).str.strip())

df = df[df['id_pozo'].isin(ids_validos)].copy()

# 4.3. Cargar staging
print(">> Cargando datos en tabla staging pozos_datos_tecnicos_stg...")
df.to_sql(
    name="pozos_datos_tecnicos_stg",
    con=engine,
    if_exists="replace",
    index=False
)

# 4.4. Validaciones en staging
with engine.begin() as con:
    print(">> Validando staging...")

    duplicados = con.execute(text("""
        SELECT id_pozo, COUNT(*)
        FROM public.pozos_datos_tecnicos_stg
        GROUP BY id_pozo
        HAVING COUNT(*) > 1;
    """)).fetchall()

    if duplicados:
        raise Exception(f"ERROR: Existen registros duplicados en datos técnicos: {duplicados}")

# 4.5. Swap atómico
with engine.begin() as con:
    print(">> Ejecutando swap atómico...")
    con.execute(text("ALTER TABLE public.pozos_datos_tecnicos RENAME TO pozos_datos_tecnicos_old;"))
    con.execute(text("ALTER TABLE public.pozos_datos_tecnicos_stg RENAME TO pozos_datos_tecnicos;"))

print(">> Swap completado. Verifica integridad antes de borrar pozos_datos_tecnicos_old.")
print(">> ETL pozos_datos_tecnicos ejecutado con éxito sin TRUNCATE.")
