⚙️ README Técnico — Pipeline ETL de AquaGISVZLA
Arquitectura profesional de extracción, limpieza, validación y carga masiva
🧩 1. Introducción
El sistema ETL de AquaGISVZLA implementa un flujo profesional de ingeniería de datos para transformar información hidrogeoespacial legacy en un modelo relacional moderno, limpio y completamente enlazado.

El pipeline está diseñado para:

garantizar integridad referencial estricta

permitir cargas masivas seguras

evitar pérdida de datos

asegurar reproducibilidad en cualquier máquina

mantener compatibilidad con PostGIS y QGIS

escalar hacia visores web y dashboards

Desde la versión actual, el sistema ya no utiliza TRUNCATE en ningún ETL.
Todos los procesos de carga masiva se realizan mediante el patrón profesional:

STAGING → VALIDACIÓN → SWAP → VERIFICACIÓN

Este patrón es estándar en sistemas empresariales, bancos, SIG institucionales y pipelines críticos.

🏗️ 2. Arquitectura General del ETL
Cada módulo ETL sigue la misma estructura:

Código
1. Extracción
2. Transformación
3. Exportación a CSV (auditoría)
4. Carga profesional en PostgreSQL:
      4.1 Crear tabla staging
      4.2 Validar integridad referencial
      4.3 Cargar staging
      4.4 Validaciones técnicas
      4.5 Swap atómico
      4.6 Verificación final
Este flujo garantiza que:

la tabla de producción nunca se borra

las tablas hijas nunca pierden integridad

los datos legacy se limpian sin riesgo

el sistema puede reproducirse en cualquier máquina

el modelo relacional se mantiene estable

🧪 3. Módulos ETL del Sistema
3.1. pozos_master
Tabla padre del sistema.
Contiene atributos físicos, administrativos y espaciales del pozo.

Validación de PK (id_pozo)

Normalización de coordenadas

Conversión de datum legacy

Swap atómico para cargas masivas

Trigger PL/pgSQL para reglas de negocio

3.2. pozos_quimica
Registros de calidad de agua.

Validación estricta contra pozos_master

Conversión de unidades

Limpieza de valores químicos

Eliminación de huérfanos

Swap atómico

3.3. pozos_litologia
Información estratigráfica del pozo.

Conversión de profundidades

Normalización de litologías

Validación de duplicados por (id_pozo, desde, hasta)

Swap atómico

3.4. pozos_nivel
Series históricas de nivel estático mensual.

Validación de año

Conversión de columnas mensuales

Validación de duplicados por (id_pozo, anio)

Swap atómico

3.5. pozos_datos_tecnicos
Atributos técnicos del pozo.

Validación 1:1 contra pozos_master

Conversión de diámetros y profundidades

Swap atómico

🔁 4. Patrón Profesional de Carga Masiva (sin TRUNCATE)
4.1. Crear tabla staging
sql
CREATE TABLE IF NOT EXISTS public.<tabla>_stg
(LIKE public.<tabla> INCLUDING ALL);
4.2. Cargar staging desde Python
python
df.to_sql("<tabla>_stg", engine, if_exists="replace", index=False)
4.3. Validar staging
PK duplicados

FK válidas

tipos correctos

fechas válidas

geometrías válidas (si aplica)

4.4. Swap atómico
sql
BEGIN;
ALTER TABLE public.<tabla> RENAME TO <tabla>_old;
ALTER TABLE public.<tabla>_stg RENAME TO <tabla>;
COMMIT;
4.5. Verificación final
conteos

vistas

integridad relacional

triggers activos

4.6. Limpieza
sql
DROP TABLE public.<tabla>_old;
🛡️ 5. Integridad Referencial
El sistema garantiza que:

ningún registro químico, litológico, técnico o de nivel puede existir sin su pozo padre

todos los ETL filtran huérfanos automáticamente

las claves foráneas están activas y validadas

las tablas _huerfanos permiten auditoría histórica

📦 6. Reproducibilidad del Sistema
El sistema puede reconstruirse en cualquier máquina mediante:

Dump binario (pg_dump -Fc)

Restauración con pg_restore

Ejecución de los ETL refactorizados

Verificación de vistas espaciales

No es necesario ejecutar scripts Python legacy ni reconstruir manualmente la BD.

🧭 7. Flujo de Trabajo Recomendado
Código
1️⃣ Actualizar funciones PL/pgSQL (si aplica)
2️⃣ Ejecutar ETL (staging + swap)
3️⃣ Validar integridad relacional
4️⃣ Verificar vista espacial en QGIS
5️⃣ Generar dump binario estable
6️⃣ Commit + Push
📚 8. Documentación Complementaria
ARQUITECTURA_SIG.md

JUSTIFICACION_MODELO_TABLAS.md

JUSTIFICACION_MODELO_VISTAS.md

ESTANDARES_NOMBRES_TABLAS.md

AquaGISVZLA.md
