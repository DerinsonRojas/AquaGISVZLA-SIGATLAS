--La creación ed esta vista permite generar un archivo shapefile de pozos con geometría en QGIS, 
a partir de la información de la tabla pozos_master.

CREATE OR REPLACE VIEW public.v_pozos_geometria_corregidaWGS84_qgis AS
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
