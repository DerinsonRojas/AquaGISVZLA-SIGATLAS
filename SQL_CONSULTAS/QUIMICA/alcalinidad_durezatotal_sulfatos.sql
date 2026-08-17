--Esta consulta es útil para analizar en conjunto el comportamiento de párametros 
--intimamente relacionados cómo los sulfatos, dureza total y alcalinidad.
--Luego se analizarán los datos en conjunto con la ubicación geografica para obtener
--un mejor entendimiento de valores que parecen outliers

WITH metricas_rangos AS (
    SELECT 
        -- Clasificación de Alcalinidad (alc)
        CASE 
            WHEN alc IS NULL THEN '1. Nulos (Sin dato)'
            WHEN alc > 0 AND alc <= 50 THEN '2. Muy baja (<50) - Corrosiva'
            WHEN alc > 50 AND alc <= 250 THEN '3. Óptima (50-250)'
            WHEN alc > 250 AND alc <= 500 THEN '4. Alta (250-500)'
            ELSE '5. Muy Alta (>500)'
        END AS rango_alcalinidad,

        -- Clasificación de Dureza Total (dtotal)
        CASE 
            WHEN dtotal IS NULL THEN '1. Nulos (Sin dato)'
            WHEN dtotal <= 75 THEN '2. Muy blanda (<75)'
            WHEN dtotal > 75 AND dtotal <= 150 THEN '3. Moderadamente dura (75-150)'
            WHEN dtotal > 150 AND dtotal <= 300 THEN '4. Dura (150-300)'
            ELSE '5. Muy dura (>300)'
        END AS rango_dureza,

        -- Clasificación de Sulfatos (so4)
        CASE 
            WHEN so4 IS NULL THEN '1. Nulos (Sin dato)'
            WHEN so4 >= 0 AND so4 <= 25 THEN '2. Muy bajo (<25)'
            WHEN so4 > 25 AND so4 <= 250 THEN '3. Óptimo (<250 norma)'
            ELSE '4. Alto (>250)'
        END AS rango_sulfatos

    FROM public.pozos_quimica
),
conteo_alcalinidad AS (
    SELECT 
        'Alcalinidad' AS parametro,
        rango_alcalinidad AS rango,
        COUNT(*) AS cantidad,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS porcentaje
    FROM metricas_rangos
    GROUP BY rango_alcalinidad
),
conteo_dureza AS (
    SELECT 
        'Dureza Total' AS parametro,
        rango_dureza AS rango,
        COUNT(*) AS cantidad,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS porcentaje
    FROM metricas_rangos
    GROUP BY rango_dureza
),
conteo_sulfatos AS (
    SELECT 
        'Sulfatos' AS parametro,
        rango_sulfatos AS rango,
        COUNT(*) AS cantidad,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS porcentaje
    FROM metricas_rangos
    GROUP BY rango_sulfatos
)
SELECT * FROM conteo_alcalinidad
UNION ALL
SELECT * FROM conteo_dureza
UNION ALL
SELECT * FROM conteo_sulfatos
ORDER BY parametro, rango;