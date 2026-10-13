"""
MÓDULO: Pipeline de Extracción, Limpieza y Carga (ETL) - Datos de Nivel de Pozos
PROYECTO: SIGATLAS - Tesis de Grado
AUTOR: DERINSON ROJAS
DESCRIPCIÓN: 
    ETL para pozos_nivel usando STAGING + VALIDACIÓN + SWAP.
    Sin TRUNCATE. Compatible con PK–FK.
"""

import pandas as pd
from sqlalchemy import create_engine, text
from dotenv import load_dotenv
import os

# ==========================================
# 1. EXTRACCIÓN
# ==========================================
print(">> Iniciando extracción de datos de pozos nivel...")

df = pd.read_csv(
    "POZOS NIVEL.txt", 
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

diccionario_nombres = {
    'iden': 'id_pozo',
    'ano': 'anio'
}
df = df.rename(columns=diccionario_nombres)

columnas_numericas = ['m1','m2','m3','m4','m5','m6','m7','m8','m9','m10','m11','m12']
for col in columnas_numericas:
    if col in df.columns:
        df[col] = pd.to_numeric(df[col], errors='coerce')

df['act_nivel'] = pd.to_datetime(df['act_nivel'], dayfirst=True, errors='coerce').dt.normalize()

# ==========================================
# 3. EXPORTACIÓN A CSV
# ==========================================
ruta_salida = os.path.join(
    os.path.dirname(__file__),
    "..", "..",
    "DATOS_PROCESADOS",
    "DATOS_POST_ETL_POZOS_NIVEL.csv"
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
        CREATE TABLE IF NOT EXISTS public.pozos_nivel_stg
        (LIKE public.pozos_nivel INCLUDING ALL);
    """))

# 4.2. Cargar datos en staging
print(">> Cargando datos en tabla staging pozos_nivel_stg...")
df.to_sql(
    name="pozos_nivel_stg",
    con=engine,
    if_exists="replace",
    index=False
)

# 4.3. Validaciones en staging
with engine.begin() as con:
    print(">> Validando staging...")

    # PK duplicados
    duplicados = con.execute(text("""
        SELECT id_pozo, anio, COUNT(*) 
        FROM public.pozos_nivel_stg
        GROUP BY id_pozo, anio
        HAVING COUNT(*) > 1;
    """)).fetchall()

    if duplicados:
        raise Exception(f"ERROR: Existen registros duplicados en staging: {duplicados}")

# 4.4. Swap atómico
with engine.begin() as con:
    print(">> Ejecutando swap atómico...")
    con.execute(text("ALTER TABLE public.pozos_nivel RENAME TO pozos_nivel_old;"))
    con.execute(text("ALTER TABLE public.pozos_nivel_stg RENAME TO pozos_nivel;"))

print(">> Swap completado. Verifica integridad antes de borrar pozos_nivel_old.")

print(">> ETL pozos_nivel ejecutado con éxito. Sistema actualizado sin TRUNCATE.")
