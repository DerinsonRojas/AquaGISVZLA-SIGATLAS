🧭 Saneamiento Geográfico y Arquitectura SIG — AquaGISVZLA
Fecha: 30 de julio de 2026
Objetivo: Completar el saneamiento geográfico de la base de datos nacional de pozos, corregir incoherencias territoriales y automatizar la transformación de coordenadas planas (PSAD56 UTM / La Canoa) a coordenadas geográficas WGS84 (EPSG:4326) mediante PostGIS.
🟩 1. Normalización Territorial y Correlación del Estado DF (Distrito Federal) por  Distrito Capital
En realidad, estos registros corresponden al antiguo Distrito Federal (DF), hoy denominado Distrito Capital.
Acciones aplicadas:
Se corrigió la columna estado en pozos_master, asignando 'DISTRITO CAPITAL' a todos los registros cuyo acrónimo territorial era DF.
Se mantuvo la nomenclatura DF en los identificadores de pozos (ej. DF-01, DF-02) para preservar la trazabilidad histórica y evitar romper relaciones existentes.
Esta normalización garantiza coherencia territorial y evita errores en la asignación de husos UTM.
🟦 2. Arquitectura de Husos UTM (Datum La Canoa / PSAD56)
La base de datos original utiliza coordenadas planas en PSAD56 UTM (La Canoa).
Para asegurar precisión en la transformación a WGS84, se definió una lógica estricta de asignación de SRID según estado, meridiano central y extensión territorial.
2.1. Huso 18N — EPSG:24718
Zulia
Táchira
Apure
Extremo oeste de Amazonas
2.2. Huso 19N — EPSG:24719
Falcón
Lara
Trujillo
Mérida
Barinas
Portuguesa
Yaracuy
Cojedes
Carabobo
Aragua
La Guaira
Distrito Capital / Distrito Federal / DF
Miranda
Sectores occidentales de Guárico, Bolívar y Amazonas
2.3. Huso 20N — EPSG:24720
Sucre
Anzoátegui
Monagas
Nueva Esparta
Sectores orientales de Guárico, Bolívar y Delta Amacuro
2.4. Huso 21N — EPSG:24721
Extremo oriental de Delta Amacuro (meridiano 60°O hacia el este)
2.5. Criterios espaciales aplicados
La asignación del SRID se realiza mediante:
Estado
Longitud aproximada (primer dígito del valor)
Coordenada Este (para casos límite)
Esta lógica se implementó directamente en la vista espacial final.
🟩 3. Vista Espacial Oficial: Transformación PSAD56 → WGS84
La vista v_pozos_geometria_corregidaWGS84_qgis realiza la transformación completa en dos pasos:
ST_SetSRID → Asigna el SRID correcto según estado/huso.
ST_Transform → Convierte la geometría a WGS84 (EPSG:4326).
Esto garantiza compatibilidad total con QGIS y con cualquier sistema global.
3.1. Vista espacial final (SQL oficial)
–BLOQUE SQL PARA LA CREACIÓN DE LA VISTA FINAL 
CREATE OR REPLACE VIEW v_pozos_geometria_corregidaWGS84_qgis AS
SELECT 
    p.*,
    ST_SetSRID(
        ST_Transform(
            ST_SetSRID(
                ST_MakePoint(p.este_m, p.norte_m), 
                CASE 
                    -- DELTA AMACURO (Transición 20N / 21N)
                    WHEN UPPER(TRIM(p.estado)) = 'DELTA AMACURO' THEN
                        CASE 
                            WHEN p.longitud::text LIKE '65%' 
                              OR p.longitud::text LIKE '64%' 
                              OR p.longitud::text LIKE '63%'
                              OR p.longitud::text LIKE '62%'
                              OR p.longitud::text LIKE '61%'
                              OR p.longitud::text LIKE '60%' THEN 24720
                            WHEN p.longitud::text LIKE '59%' 
                              OR p.longitud::text LIKE '58%' 
                              OR p.longitud::text LIKE '57%' THEN 24721
                            ELSE 24720
                        END

                    -- AMAZONAS (Transición 18N / 19N)
                    WHEN UPPER(TRIM(p.estado)) = 'AMAZONAS' THEN
                        CASE 
                            WHEN p.longitud::text LIKE '73%' 
                              OR p.longitud::text LIKE '72%' THEN 24718
                            ELSE 24719
                        END

                    -- BOLÍVAR (Transición 19N / 20N)
                    WHEN UPPER(TRIM(p.estado)) IN ('BOLIVAR', 'BOLÍVAR') THEN
                        CASE 
                            WHEN p.longitud::text LIKE '71%' 
                              OR p.longitud::text LIKE '70%'
                              OR p.longitud::text LIKE '69%'
                              OR p.longitud::text LIKE '68%'
                              OR p.longitud::text LIKE '67%'
                              OR p.longitud::text LIKE '66%' THEN 24719
                            ELSE 24720
                        END

                    -- ZULIA, TÁCHIRA, APURE (Transición 18N / 19N)
                    WHEN UPPER(TRIM(p.estado)) IN ('ZULIA', 'TACHIRA', 'APURE') THEN
                        CASE 
                            WHEN p.longitud::text LIKE '73%' 
                              OR p.longitud::text LIKE '72%' THEN 24718
                            WHEN p.longitud::text LIKE '71%' 
                              OR p.longitud::text LIKE '70%' THEN 24719
                            WHEN p.este_m < 500000 THEN 24718
                            ELSE 24719
                        END

                    -- GUÁRICO (Transición 19N / 20N)
                    WHEN UPPER(TRIM(p.estado)) IN ('GUARICO', 'GUÁRICO') THEN
                        CASE 
                            WHEN p.longitud::text LIKE '65%' 
                              OR p.longitud::text LIKE '64%' 
                              OR p.longitud::text LIKE '63%' THEN 24720
                            ELSE 24719
                        END

                    -- HUSO 19N (Unihuso + Distrito Capital/DF)
                    WHEN UPPER(TRIM(p.estado)) IN (
                        'FALCON', 'MERIDA', 'BARINAS', 'PORTUGUESA', 
                        'LARA', 'TRUJILLO', 'CARABOBO', 'COJEDES', 'ARAGUA', 
                        'VARGAS', 'LA GUAIRA', 'YARACUY', 'DISTRITO CAPITAL',
                        'DISTRITO FEDERAL', 'DF', 'MIRANDA'
                    ) THEN 24719

                    -- HUSO 20N (Unihuso)
                    WHEN UPPER(TRIM(p.estado)) IN (
                        'SUCRE', 'NUEVA ESPARTA', 'ANZOATEGUI', 'MONAGAS'
                    ) THEN 24720
                END
            ), 
            4326
        ),
        4326
    )::geometry(Point, 4326) AS geom
FROM public.pozos_master p
WHERE p.tiene_geometria = TRUE 
  AND p.este_m IS NOT NULL 
  AND p.norte_m IS NOT NULL;

3.2. Características de la vista
Geometría válida en formato Point.
SRID final: 4326.
Compatible con QGIS, Leaflet, GeoServer y cualquier visor SIG.
No altera la tabla base pozos_master.
Mantiene todos los atributos originales del pozo.
🟦 4. Tabla spatial_ref_sys y su rol en la arquitectura
La tabla spatial_ref_sys es creada automáticamente por PostGIS al ejecutar:
sql
CREATE EXTENSION postgis;

Esta tabla contiene:
SRID oficiales
WKT de cada sistema
PROJ4
Información necesaria para transformaciones y validaciones
QGIS consulta esta tabla cada vez que se conecta para validar SRID y dibujar geometrías correctamente.
🟩 5. Estado Actual del Saneamiento SIG
100% de los estados de Venezuela integrados en la lógica de husos.
Vista espacial final creada y validada.
Corrección territorial completada (DF → Distrito Capital).
Pozos sin geometría identificados mediante tiene_geometria = FALSE.
Transformación PSAD56 → WGS84 automatizada.
🟦 6. Próximos Pasos
6.1. Crear vista/tabla de auditoría SIG
Objetivo:
Registrar pozos excluidos por falta de geometría
Detectar valores fuera de rango
Identificar coordenadas imposibles
Documentar errores espaciales para corrección futura
Nombre recomendado:
Código
auditoria_pozos_fuera_de_rango

6.2. Crear vistas derivadas para análisis SIG
Buffers (500 m, 1 km)
Distancias entre pozos
Intersecciones con acuíferos
Mapas de calor
Densidad de pozos por municipio
⭐ Conclusión
Este documento consolida toda la arquitectura SIG del proyecto AquaGISVZLA:
saneamiento territorial,
lógica de husos UTM,
transformaciones PSAD56 → WGS84,
vista espacial final para QGIS,
estado actual y próximos pasos.
Es la base para cualquier expansión futura del sistema espacial.
