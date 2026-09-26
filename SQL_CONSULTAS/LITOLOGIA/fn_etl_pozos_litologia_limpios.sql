-- Función: limpiar_litologia_huerfanos
-- Propósito: depurar registros de pozos_litologia antes de insertarlos o actualizarlos.
-- Reglas:
--   1. El pozo debe existir en pozos_master.
--   2. El campo litología no puede ser nulo.
--   3. Eliminar espacios y la letra X al final del texto.
--   4. Evitar duplicados con fecha diferente.


CREATE OR REPLACE FUNCTION fn_etl_pozos_litologia_limpios()
RETURNS TRIGGER AS $$
DECLARE
    fecha_dominante DATE;
BEGIN
    -- Regla: Si el pozo no existe en master
    IF NOT EXISTS (
        SELECT 1 FROM public.pozos_master
        WHERE id_pozo = NEW.id_pozo
    ) THEN
        RETURN NULL;
    END IF;

    -- Regla: Eliminar registros que después de la litología tienen espacios y al final la letra X
    NEW.litologia := TRIM(
        REGEXP_REPLACE(
            NEW.litologia,
            '\s*X\s*$',
            '',
            'i'
        )
    );

    -- Regla: La litología no puede ser nula
    IF NEW.litologia IS NULL THEN
        RETURN NULL;
    END IF;

    -- Regla: evitar duplicados con fecha diferente
    IF EXISTS (
        SELECT 1
        FROM public.pozos_litologia
        WHERE id_pozo = NEW.id_pozo
          AND desde = NEW.desde
          AND hasta = NEW.hasta
          AND litologia = NEW.litologia
          AND act_litologia <> NEW.act_litologia
    ) THEN
        RETURN NULL;
    END IF;

    -- Regla: unificar fecha según mayoría
    SELECT act_litologia
    INTO fecha_dominante
    FROM public.pozos_litologia
    WHERE id_pozo = NEW.id_pozo
    GROUP BY act_litologia
    ORDER BY COUNT(*) DESC
    LIMIT 1;

    IF fecha_dominante IS NULL THEN
        fecha_dominante := '1994-01-18';
    END IF;

    NEW.act_litologia := fecha_dominante;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
