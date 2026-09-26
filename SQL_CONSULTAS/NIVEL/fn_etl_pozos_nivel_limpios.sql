
-- Función: limpiar_nivel
CREATE OR REPLACE FUNCTION fn_etl_pozos_nivel_limpios()
RETURNS TRIGGER AS $$
BEGIN
    -- Regla 1: Si el pozo no existe en master
    IF NOT EXISTS (
        SELECT 1 FROM public.pozos_master
        WHERE id_pozo = NEW.id_pozo
    ) THEN
        RETURN NULL;
    END IF;

    -- Regla 2: Validación del año
    IF NEW.anio IS NULL
       OR NEW.anio = 1900
       OR NEW.anio < 1901
       OR NEW.anio > 2100
    THEN
        RETURN NULL;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
