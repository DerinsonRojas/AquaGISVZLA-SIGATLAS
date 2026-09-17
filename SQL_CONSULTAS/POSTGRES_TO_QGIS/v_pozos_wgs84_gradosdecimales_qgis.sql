/*Se crea esta vista para aprovechar que se han creado indices en todas las tablas y se han calculados las coordenadas en grados decimales
para cada punto. Como esta vista no tendra que calcular las coordenadas norte, este, a partir de los husos sino que ubica los puntos 
con grados decimales será notablemente más ágil pensando en el futuro desarrollo del visor web leaflet*/

CREATE OR REPLACE VIEW public.v_pozos_wgs84_gradosdecimales_qgis AS
SELECT 
    m.id_pozo,
    m.municipio,--No es literal es un número de la data legacy
    m.sitio,
    m.nombre,
    m.propietario,
    m.estado,
    --Clasificación del pozo según su correcta ubicación espacial 
    m.auditoria_estado,
    
    -- Coordenadas originales (legacy/UTM) por si necesitas consultarlas
    m.latitud,
    m.longitud,
    m.norte_m,
    m.este_m,
    
    -- Altitud
    m.altitud_msnm,
    m.altitud_origen,
    
    -- Coordenadas limpias en grados decimales  
    ROUND(g.lat_dd::numeric, 6) AS lat_dd,
    ROUND(g.lon_dd::numeric, 6) AS lon_dd,
    -- Geometría WGS84
    g.geom_wgs84 AS geom,
    
    -- Indicadores de tablas hijas
    EXISTS (SELECT 1 FROM public.pozos_quimica q WHERE q.id_pozo = m.id_pozo) AS tiene_quimica,
    EXISTS (SELECT 1 FROM public.pozos_litologia_limpios l WHERE l.id_pozo = m.id_pozo) AS tiene_litologia,
    EXISTS (SELECT 1 FROM public.pozos_nivel_limpios n WHERE n.id_pozo = m.id_pozo) AS tiene_niveles,
    EXISTS (SELECT 1 FROM public.pozos_fisicos f WHERE f.id_pozo = m.id_pozo) AS tiene_fisicos

FROM public.pozos_master AS m
INNER JOIN public.pozos_grados_decimales_wgs84 AS g 
    ON m.id_pozo = g.id_pozo
WHERE m.tiene_geometria = TRUE
  AND g.geom_wgs84 IS NOT NULL;