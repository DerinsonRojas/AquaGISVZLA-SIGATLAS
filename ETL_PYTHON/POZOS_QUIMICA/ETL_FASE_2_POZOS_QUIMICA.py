"""
MÓDULO: Pipeline de Extracción, Limpieza y Carga (ETL) - Datos de Quimica de Pozos
PROYECTO: Prueba de Concepto - Tesis de Grado
AUTOR: DERINSON ROJAS
DESCRIPCIÓN: 
    Script de ETL y conexión a BBDD PostgreSQL funcional con validación estricta de integridad referencial.
"""

import os
import pandas as pd
import numpy as np
from sqlalchemy import create_engine, text
from dotenv import load_dotenv


# ==========================================
# 1. EXTRACCIÓN (Ingesta de datos crudos)
# ==========================================
print(">> Iniciando extracción de datos...")
df = pd.read_csv(
    "pozosQuimica.txt", 
    sep=";", 
    encoding="Latin-1",
    na_values=["", " "],       
    skipinitialspace=True,
    quotechar='"'       
)

# ==========================================
# 2. TRANSFORMACIÓN (Reglas de Ingeniería de Datos)
# ==========================================

# 2.1. Diccionario de Renombramiento Formal (Estandarización de Esquema)
df.columns = df.columns.str.lower()

diccionario_nombres = {
    'iden': 'id_pozo',
    'temp': 'temperatura_c',
    'conduc':'conductividad_us_cm'
}
df = df.rename(columns=diccionario_nombres)

# Asegurar que id_pozo sea string limpio y sin espacios
if 'id_pozo' in df.columns:
    df['id_pozo'] = df['id_pozo'].astype(str).str.strip()

# 2.2. Limpieza de columnas numéricas
columnas_numericas = ['temperatura_c','ph','indice','conductividad_us_cm','alc','dtotal','tsd','ras','cl','so4',
                      'f','no2','no3','sio2','hco3','co3','fe','mn','b','duca','ca','mg','na','k',
                      'cu','zn','pb','po4']

for col in columnas_numericas:
    if col in df.columns:
        df[col] = df[col].astype(str).str.replace(',', '.', regex=False)
        df[col] = pd.to_numeric(df[col], errors='coerce')

# 2.3. Estandarización de Fechas (ACT_QUIMI)
if 'act_quimi' in df.columns:
    df['act_quimi'] = pd.to_datetime(df['act_quimi'], dayfirst=True, errors='coerce').dt.normalize()

    total_nulos = df['act_quimi'].isna().sum()
    if total_nulos > 0:
        print(f">> Atención: {total_nulos} valores en 'act_quimi' no pudieron convertirse a fecha y se han convertido en NaT.")

# ==========================================
# 3. EXPORTACIÓN A CSV (DATOS_PROCESADOS)
# ==========================================
ruta_salida = os.path.join(
    os.path.dirname(__file__), "..","..",
    "DATOS_PROCESADOS", 
    "DATOS_POST_ETL_POZOS_QUIMICA.csv"
)

print(">> Exportando archivo plano CSV...")
df.to_csv(ruta_salida, index=False, encoding="utf-8", sep=";")     

# ==========================================
# 4. CARGA EN POSTGRESQL (VALIDACIÓN + TRUNCATE + APPEND)
# ==========================================
print(">> Conectando con PostgreSQL para la carga...")
load_dotenv()
USER = os.getenv('DB_USER')
PASSWORD = os.getenv('DB_PASSWORD')
HOST = os.getenv('DB_HOST')
PORT = os.getenv('DB_PORT')
DB_NAME = os.getenv('DB_NAME')

URL_CONEXION = f'postgresql://{USER}:{PASSWORD}@{HOST}:{PORT}/{DB_NAME}'
engine = create_engine(URL_CONEXION)

# 4.1. Cargar IDs válidos desde pozos_master y normalizarlos
print(">> Consultando integridad referencial con 'pozos_master'...")
query_ids_validos = "SELECT id_pozo FROM public.pozos_master;"
df_validos = pd.read_sql(query_ids_validos, con=engine)

# Normalizamos a string, quitamos espacios para evitar falsos negativos por formato
ids_validos_set = set(df_validos['id_pozo'].astype(str).str.strip())
print(f">> Total de pozos válidos encontrados en 'pozos_master': {len(ids_validos_set)}")

# Diagnóstico específico del pozo que dio error
pozo_test = "AN6143001A"
if pozo_test in df['id_pozo'].values:
    print(f">> [DIAGNÓSTICO] El pozo conflictivo '{pozo_test}' está presente en el archivo de química.")
    if pozo_test in ids_validos_set:
        print(f">> [DIAGNÓSTICO] El pozo '{pozo_test}' SÍ está en pozos_master (revisa por qué falló la FK).")
    else:
        print(f">> [DIAGNÓSTICO] El pozo '{pozo_test}' NO está en pozos_master. Será descartado correctamente.")

# 4.2. Filtrar registros huérfanos de manera estricta
total_antes = len(df)
df = df[df['id_pozo'].isin(ids_validos_set)].copy()
total_despues = len(df)

registros_descartados = total_antes - total_despues
print(f">> Integridad aplicada: Se descartaron {registros_descartados} registros huérfanos.")
print(f">> Registros listos para insertar en PostgreSQL: {total_despues}")

# 4.3. Vaciar tabla de química manteniendo estructura
with engine.begin() as con:
    print(">> TRUNCATE TABLE pozos_quimica...")
    con.execute(text("TRUNCATE TABLE public.pozos_quimica;"))

# 4.4. Inyección de datos limpios y filtrados
if not df.empty:
    df.to_sql(
        name="pozos_quimica", 
        con=engine, 
        if_exists="append", 
        index=False
    )
    print(">> Pipeline Fase 2 de química ejecutado con éxito total.")
else:
    print(">> ADVERTENCIA: No hay registros válidos para insertar después del filtro con 'pozos_master'.")