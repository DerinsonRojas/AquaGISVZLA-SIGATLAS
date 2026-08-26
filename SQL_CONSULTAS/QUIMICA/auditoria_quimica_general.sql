CREATE OR REPLACE FUNCTION auditoria_quimica_general()
RETURNS void AS $$
DECLARE
    r RECORD;
    motivo TEXT;
BEGIN
    FOR r IN
        SELECT *
        FROM pozos_quimica
    LOOP
        ------------------------------------------------------------------
        -- NO3
        ------------------------------------------------------------------
        IF r.no3 IS NOT NULL AND (r.no3 < 0 OR r.no3 > 200) THEN
            motivo := CASE
                        WHEN r.no3 < 0 THEN 'NO3 negativo, no físico'
                        ELSE 'NO3 mayor a 200 mg/L, fuera de rango'
                      END;
            INSERT INTO auditoria_quimica (id_pozo, columna, valor_original, valor_nuevo, motivo)
            VALUES (r.id_pozo, 'no3', r.no3::TEXT, NULL, motivo);
        END IF;

        ------------------------------------------------------------------
        -- SiO2
        ------------------------------------------------------------------
        IF r.sio2 IS NOT NULL AND (r.sio2 < 0 OR r.sio2 > 100) THEN
            motivo := CASE
                        WHEN r.sio2 < 0 THEN 'SiO2 negativo'
                        ELSE 'SiO2 mayor a 100 mg/L'
                      END;
            INSERT INTO auditoria_quimica VALUES (DEFAULT, r.id_pozo, 'sio2', r.sio2::TEXT, NULL, motivo, NOW());
        END IF;

        ------------------------------------------------------------------
        -- HCO3
        ------------------------------------------------------------------
        IF r.hco3 IS NOT NULL AND (r.hco3 < 0 OR r.hco3 > 500) THEN
            motivo := CASE
                        WHEN r.hco3 < 0 THEN 'HCO3 negativo'
                        ELSE 'HCO3 mayor a 500 mg/L'
                      END;
            INSERT INTO auditoria_quimica VALUES (DEFAULT, r.id_pozo, 'hco3', r.hco3::TEXT, NULL, motivo, NOW());
        END IF;

        ------------------------------------------------------------------
        -- CO3
        ------------------------------------------------------------------
        IF r.co3 IS NOT NULL AND (r.co3 < 0 OR r.co3 > 50) THEN
            motivo := CASE
                        WHEN r.co3 < 0 THEN 'CO3 negativo'
                        ELSE 'CO3 mayor a 50 mg/L'
                      END;
            INSERT INTO auditoria_quimica VALUES (DEFAULT, r.id_pozo, 'co3', r.co3::TEXT, NULL, motivo, NOW());
        END IF;

        ------------------------------------------------------------------
        -- Fe
        ------------------------------------------------------------------
        IF r.fe IS NOT NULL AND (r.fe < 0 OR r.fe > 10) THEN
            motivo := CASE
                        WHEN r.fe < 0 THEN 'Fe negativo'
                        ELSE 'Fe mayor a 10 mg/L'
                      END;
            INSERT INTO auditoria_quimica VALUES (DEFAULT, r.id_pozo, 'fe', r.fe::TEXT, NULL, motivo, NOW());
        END IF;

        ------------------------------------------------------------------
        -- Mn
        ------------------------------------------------------------------
        IF r.mn IS NOT NULL AND (r.mn < 0 OR r.mn > 5) THEN
            motivo := CASE
                        WHEN r.mn < 0 THEN 'Mn negativo'
                        ELSE 'Mn mayor a 5 mg/L'
                      END;
            INSERT INTO auditoria_quimica VALUES (DEFAULT, r.id_pozo, 'mn', r.mn::TEXT, NULL, motivo, NOW());
        END IF;

        ------------------------------------------------------------------
        -- Boro
        ------------------------------------------------------------------
        IF r.b IS NOT NULL AND (r.b < 0 OR r.b > 10) THEN
            motivo := CASE
                        WHEN r.b < 0 THEN 'B negativo'
                        ELSE 'B mayor a 10 mg/L'
                      END;
            INSERT INTO auditoria_quimica VALUES (DEFAULT, r.id_pozo, 'b', r.b::TEXT, NULL, motivo, NOW());
        END IF;

        ------------------------------------------------------------------
        -- DUCA
        ------------------------------------------------------------------
        IF r.duca IS NOT NULL AND (r.duca < 0 OR r.duca > 500) THEN
            motivo := CASE
                        WHEN r.duca < 0 THEN 'DUCA negativo'
                        ELSE 'DUCA mayor a 500 mg/L'
                      END;
            INSERT INTO auditoria_quimica VALUES (DEFAULT, r.id_pozo, 'duca', r.duca::TEXT, NULL, motivo, NOW());
        END IF;

        ------------------------------------------------------------------
        -- Na
        ------------------------------------------------------------------
        IF r.na IS NOT NULL AND (r.na < 0 OR r.na > 500) THEN
            motivo := CASE
                        WHEN r.na < 0 THEN 'Na negativo'
                        ELSE 'Na mayor a 500 mg/L'
                      END;
            INSERT INTO auditoria_quimica VALUES (DEFAULT, r.id_pozo, 'na', r.na::TEXT, NULL, motivo, NOW());
        END IF;

        ------------------------------------------------------------------
        -- K
        ------------------------------------------------------------------
        IF r.k IS NOT NULL AND (r.k < 0 OR r.k > 50) THEN
            motivo := CASE
                        WHEN r.k < 0 THEN 'K negativo'
                        ELSE 'K mayor a 50 mg/L'
                      END;
            INSERT INTO auditoria_quimica VALUES (DEFAULT, r.id_pozo, 'k', r.k::TEXT, NULL, motivo, NOW());
        END IF;

        ------------------------------------------------------------------
        -- Cu
        ------------------------------------------------------------------
        IF r.cu IS NOT NULL AND (r.cu < 0 OR r.cu > 5) THEN
            motivo := CASE
                        WHEN r.cu < 0 THEN 'Cu negativo'
                        ELSE 'Cu mayor a 5 mg/L'
                      END;
            INSERT INTO auditoria_quimica VALUES (DEFAULT, r.id_pozo, 'cu', r.cu::TEXT, NULL, motivo, NOW());
        END IF;

        ------------------------------------------------------------------
        -- Zn
        ------------------------------------------------------------------
        IF r.zn IS NOT NULL AND (r.zn < 0 OR r.zn > 10) THEN
            motivo := CASE
                        WHEN r.zn < 0 THEN 'Zn negativo'
                        ELSE 'Zn mayor a 10 mg/L'
                      END;
            INSERT INTO auditoria_quimica VALUES (DEFAULT, r.id_pozo, 'zn', r.zn::TEXT, NULL, motivo, NOW());
        END IF;

        ------------------------------------------------------------------
        -- Pb
        ------------------------------------------------------------------
        IF r.pb IS NOT NULL AND (r.pb < 0 OR r.pb > 1) THEN
            motivo := CASE
                        WHEN r.pb < 0 THEN 'Pb negativo'
                        ELSE 'Pb mayor a 1 mg/L'
                      END;
            INSERT INTO auditoria_quimica VALUES (DEFAULT, r.id_pozo, 'pb', r.pb::TEXT, NULL, motivo, NOW());
        END IF;

        ------------------------------------------------------------------
        -- PO4
        ------------------------------------------------------------------
        IF r.po4 IS NOT NULL AND (r.po4 < 0 OR r.po4 > 20) THEN
            motivo := CASE
                        WHEN r.po4 < 0 THEN 'PO4 negativo'
                        ELSE 'PO4 mayor a 20 mg/L'
                      END;
            INSERT INTO auditoria_quimica VALUES (DEFAULT, r.id_pozo, 'po4', r.po4::TEXT, NULL, motivo, NOW());
        END IF;

        ------------------------------------------------------------------
        -- Fluor (F)
        ------------------------------------------------------------------
        IF r.f IS NOT NULL AND (r.f < 0 OR r.f = -1 OR r.f = 11.11 OR r.f > 20) THEN
            motivo := CASE
                        WHEN r.f < 0 OR r.f = -1 THEN 'F negativo o -1'
                        WHEN r.f = 11.11 THEN 'F placeholder legacy'
                        WHEN r.f > 50 THEN 'F mayor a 50 mg/L, no físico'
                        ELSE 'F mayor a 20 mg/L, sospechoso'
                      END;
            INSERT INTO auditoria_quimica VALUES (DEFAULT, r.id_pozo, 'f', r.f::TEXT, NULL, motivo, NOW());
        END IF;

        ------------------------------------------------------------------
        -- NO2
        ------------------------------------------------------------------
        IF r.no2 IS NOT NULL AND (r.no2 < 0 OR r.no2 > 10) THEN
            motivo := CASE
                        WHEN r.no2 < 0 THEN 'NO2 negativo'
                        ELSE 'NO2 mayor a 10 mg/L'
                      END;
            INSERT INTO auditoria_quimica VALUES (DEFAULT, r.id_pozo, 'no2', r.no2::TEXT, NULL, motivo, NOW());
        END IF;
        
        ------------------------------------------------------------------
        -- f
        ------------------------------------------------------------------
         IF r.f IS NOT NULL AND (r.f < 0 OR r.f = -1 OR r.f = 11.11 OR r.f > 20) THEN
         motivo := CASE
                WHEN r.f < 0 OR r.f = -1 THEN 'F negativo o -1'
                WHEN r.f = 11.11 THEN 'F placeholder legacy'
                WHEN r.f > 50 THEN 'F mayor a 50 mg/L, no físico'
                ELSE 'F mayor a 20 mg/L, sospechoso'
        END;

        INSERT INTO auditoria_quimica
        VALUES (DEFAULT, r.id_pozo, 'f', r.f::TEXT, NULL, motivo, NOW());
        END IF;
        ------------------------------------------------------------------
        -- no2
        ------------------------------------------------------------------
        IF r.no2 IS NOT NULL AND (r.no2 < 0 OR r.no2 > 10) THEN
        motivo := CASE
                WHEN r.no2 < 0 THEN 'NO2 negativo'
                ELSE 'NO2 mayor a 10 mg/L'
        END;
        ------------------------------------------------------------------
        -- conductividad_us_cm
        ------------------------------------------------------------------
        IF r.conductividad_us_cm IS NOT NULL AND r.conductividad_us_cm < 0 THEN
            INSERT INTO auditoria_quimica
            VALUES (DEFAULT, r.id_pozo, 'conductividad_us_cm', r.conductividad_us_cm::TEXT, NULL,
                    'Conductividad negativa', NOW());
        END IF;
        ------------------------------------------------------------------
        -- so4, ca, mg
        ------------------------------------------------------------------
        IF r.so4 IS NOT NULL AND r.so4 < 0 THEN
            INSERT INTO auditoria_quimica
            VALUES (DEFAULT, r.id_pozo, 'so4', r.so4::TEXT, NULL, 'SO4 negativo', NOW());
        END IF;

        IF r.ca IS NOT NULL AND r.ca = 0 THEN
            INSERT INTO auditoria_quimica
            VALUES (DEFAULT, r.id_pozo, 'ca', r.ca::TEXT, NULL, 'Ca igual a 0, no físico', NOW());
        END IF;

        IF r.mg IS NOT NULL AND r.mg = 0 THEN
            INSERT INTO auditoria_quimica
            VALUES (DEFAULT, r.id_pozo, 'mg', r.mg::TEXT, NULL, 'Mg igual a 0, no físico', NOW());
        END IF;

        ------------------------------------------------------------------
        -- alc
        ------------------------------------------------------------------       
        IF r.alc IS NOT NULL AND (r.alc <= 0 OR r.alc = -1 OR r.alc > 1500) THEN
        motivo := CASE
                WHEN r.alc <= 0 THEN 'Alcalinidad <= 0'
                WHEN r.alc = -1 THEN 'Alcalinidad -1 (placeholder)'
                ELSE 'Alcalinidad > 1500 mg/L'
        END;
        ------------------------------------------------------------------
        -- cl
        ------------------------------------------------------------------ 
        IF r.cl IS NOT NULL AND r.cl < 0 THEN
            INSERT INTO auditoria_quimica
            VALUES (DEFAULT, r.id_pozo, 'cl', r.cl::TEXT, NULL, 'Cl negativo', NOW());
        END IF;
        ------------------------------------------------------------------
        -- tsd
        ------------------------------------------------------------------ 
        IF r.tsd IS NOT NULL AND r.tsd <= 10 THEN
            INSERT INTO auditoria_quimica
            VALUES (DEFAULT, r.id_pozo, 'tsd', r.tsd::TEXT, NULL, 'TSD <= 10 mg/L', NOW());
        END IF;
        ------------------------------------------------------------------
        -- temperarura_c
        ------------------------------------------------------------------ 
        IF r.temperatura_c IS NOT NULL AND r.temperatura_c = 0 THEN
            INSERT INTO auditoria_quimica
            VALUES (DEFAULT, r.id_pozo, 'temperatura_c', r.temperatura_c::TEXT, NULL,
                    'Temperatura igual a 0', NOW());
        END IF;
        ------------------------------------------------------------------
        -- ph
        ------------------------------------------------------------------ 
        IF r.ph IS NOT NULL AND (r.ph < 0 OR r.ph > 14 OR r.ph < 4 OR r.ph > 10) THEN
        motivo := CASE
                WHEN r.ph < 0 OR r.ph > 14 THEN 'pH fuera del rango físico (0–14)'
                ELSE 'pH fuera del rango hidrogeoquímico (4–10)'
        END;

    INSERT INTO auditoria_quimica
    VALUES (DEFAULT, r.id_pozo, 'ph', r.ph::TEXT, NULL, motivo, NOW());
END IF;

    INSERT INTO auditoria_quimica
    VALUES (DEFAULT, r.id_pozo, 'alc', r.alc::TEXT, NULL, motivo, NOW());
END IF;


    INSERT INTO auditoria_quimica
    VALUES (DEFAULT, r.id_pozo, 'no2', r.no2::TEXT, NULL, motivo, NOW());
END IF;



    END LOOP;

END;
$$ LANGUAGE plpgsql;
