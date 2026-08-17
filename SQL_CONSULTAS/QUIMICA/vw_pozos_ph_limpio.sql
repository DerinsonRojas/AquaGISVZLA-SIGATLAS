--Vista crada para normalizar la entrada fuera de rango de valores de ph
CREATE OR REPLACE VIEW vw_pozos_ph_limpio AS
SELECT 
    id_pozo,
    CASE 
        WHEN ph < 0 OR ph > 14 THEN NULL 
        WHEN ph < 4 OR ph > 10 THEN NULL 
        ELSE ph 
    END AS ph_limpio
FROM public.pozos_quimica
WHERE ph IS NOT NULL 
  AND ph >= 0 AND ph <= 14;   