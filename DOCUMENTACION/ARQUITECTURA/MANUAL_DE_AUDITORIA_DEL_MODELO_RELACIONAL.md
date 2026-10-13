📑 MANUAL DE AUDITORÍA DEL MODELO RELACIONAL — AquaGISVZLA
Procedimientos oficiales para verificar integridad, consistencia y trazabilidad del sistema hidrogeoespacial
🧭 1. Objetivo del Manual
Este manual define los procedimientos técnicos para auditar el modelo relacional de AquaGISVZLA, garantizando:
integridad referencial estricta
ausencia de registros huérfanos
consistencia entre tablas padre e hijas
validez de claves primarias
coherencia de tipos de datos
estabilidad de vistas espaciales
trazabilidad de datos legacy
compatibilidad con el pipeline ETL profesional
La auditoría es obligatoria:
antes de generar un dump binario
después de ejecutar los ETL
antes de publicar dashboards o visores web
antes de cualquier entrega académica
después de migraciones o restauraciones
🧩 2. Componentes del Modelo Relacional
El modelo está compuesto por cinco tablas principales:
Tabla
Rol
Relación
pozos_master
Tabla raíz
PK principal
pozos_quimica
Calidad del agua
1:N
pozos_litologia
Estratigrafía
1:N
pozos_nivel
Series históricas
1:N
pozos_datos_tecnicos
Atributos técnicos
1:1

Además, existen tablas auxiliares:
_limpios
_huerfanos
staging (*_stg)
vistas espaciales (v_pozos_geometria_corregidaWGS84_qgis)
🛡️ 3. Auditoría de Integridad Referencial (FK)
3.1. Verificar que no existan huérfanos
sql
SELECT q.id_pozo
FROM pozos_quimica q
LEFT JOIN pozos_master m ON q.id_pozo = m.id_pozo
WHERE m.id_pozo IS NULL;

Repetir para litología, nivel y datos técnicos:
sql
-- Litología
SELECT l.id_pozo FROM pozos_litologia l
LEFT JOIN pozos_master m ON l.id_pozo = m.id_pozo
WHERE m.id_pozo IS NULL;

-- Nivel
SELECT n.id_pozo FROM pozos_nivel n
LEFT JOIN pozos_master m ON n.id_pozo = m.id_pozo
WHERE m.id_pozo IS NULL;

-- Datos técnicos
SELECT t.id_pozo FROM pozos_datos_tecnicos t
LEFT JOIN pozos_master m ON t.id_pozo = m.id_pozo
WHERE m.id_pozo IS NULL;

Interpretación
Si el resultado está vacío → integridad referencial OK
Si aparecen registros → deben enviarse a tablas _huerfanos
🔐 4. Auditoría de Claves Primarias (PK)
4.1. pozos_master
sql
SELECT id_pozo, COUNT(*)
FROM pozos_master
GROUP BY id_pozo
HAVING COUNT(*) > 1;

4.2. pozos_quimica
sql
SELECT id_pozo, act_quimi, COUNT(*)
FROM pozos_quimica
GROUP BY id_pozo, act_quimi
HAVING COUNT(*) > 1;

4.3. pozos_litologia
sql
SELECT id_pozo, desde, hasta, COUNT(*)
FROM pozos_litologia
GROUP BY id_pozo, desde, hasta
HAVING COUNT(*) > 1;

4.4. pozos_nivel
sql
SELECT id_pozo, anio, COUNT(*)
FROM pozos_nivel
GROUP BY id_pozo, anio
HAVING COUNT(*) > 1;

4.5. pozos_datos_tecnicos
sql
SELECT id_pozo, COUNT(*)
FROM pozos_datos_tecnicos
GROUP BY id_pozo
HAVING COUNT(*) > 1;

Interpretación
Si no hay resultados → PK válidas
Si hay duplicados → revisar ETL y staging
🧪 5. Auditoría de Tipos de Datos
5.1. Verificar columnas numéricas
sql
SELECT *
FROM pozos_quimica
WHERE ph IS NULL AND temperatura_c IS NULL AND conductividad_us_cm IS NULL;

5.2. Verificar columnas de fecha
sql
SELECT *
FROM pozos_master
WHERE act_master IS NULL;

5.3. Verificar columnas espaciales
sql
SELECT id_pozo
FROM pozos_master
WHERE geom_wgs84 IS NULL;

🌐 6. Auditoría Espacial (PostGIS)
6.1. Verificar geometrías válidas
sql
SELECT id_pozo
FROM pozos_master
WHERE NOT ST_IsValid(geom_wgs84);

6.2. Verificar geometrías dentro de Venezuela
sql
SELECT id_pozo
FROM pozos_master
WHERE ST_Within(
    geom_wgs84,
    ST_GeomFromText('POLYGON((...))', 4326)  -- polígono de Venezuela
) IS FALSE;

6.3. Verificar vista espacial oficial
sql
SELECT COUNT(*) FROM v_pozos_geometria_corregidaWGS84_qgis;

🔁 7. Auditoría del Pipeline ETL (Staging + Swap)
7.1. Verificar staging vacía después del swap
sql
SELECT COUNT(*) FROM pozos_master_stg;

Debe ser 0.
7.2. Verificar tabla _old eliminada
sql
SELECT table_name
FROM information_schema.tables
WHERE table_name LIKE '%_old';

Debe estar vacía.
7.3. Verificar que el swap se ejecutó correctamente
sql
SELECT COUNT(*) FROM pozos_master;

Debe coincidir con:
sql
SELECT COUNT(*) FROM DATOS_PROCESADOS/DATOS_POST_ETL_POZOS_MASTER_LIMPIO.csv

🧾 8. Auditoría de Trazabilidad Legacy
8.1. Verificar tabla _huerfanos
sql
SELECT COUNT(*) FROM pozos_master_huerfanos;

8.2. Verificar tabla _limpios
sql
SELECT COUNT(*) FROM pozos_master_limpios;

Interpretación
_limpios debe crecer con cada ETL
_huerfanos debe disminuir con cada mejora del modelo
📊 9. Auditoría de Vistas y Funciones PL/pgSQL
9.1. Verificar vistas críticas
sql
SELECT COUNT(*) FROM v_pozos_relaciones;
SELECT COUNT(*) FROM v_pozos_geometria_corregidaWGS84_qgis;

9.2. Verificar triggers activos
sql
SELECT event_manipulation, trigger_name
FROM information_schema.triggers
WHERE event_object_table = 'pozos_master';

🛠️ 10. Checklist Final de Auditoría
Antes de generar un dump o publicar resultados:
[ ] No existen huérfanos
[ ] No existen duplicados en PK
[ ] Todas las FKs son válidas
[ ] Todas las geometrías son válidas
[ ] Todas las vistas espaciales funcionan
[ ] Todas las tablas staging están vacías
[ ] No existen tablas _old
[ ] Los ETL se ejecutaron sin errores
[ ] La documentación está actualizada
🎯 11. Conclusión
Este manual garantiza que el modelo relacional de AquaGISVZLA se mantenga:
íntegro
estable
reproducible
científicamente confiable
compatible con SIG
listo para análisis avanzados
La auditoría es parte esencial del ciclo de vida del sistema y asegura que la información hidrogeoespacial de Venezuela se preserve con calidad profesional.
👤 Autor
Derinson Rojas  
Ingeniero Geólogo | SIG & ETL Developer
Proyecto AquaGISVZLA — Modernización hidrogeoespacial de Venezuela.
