CREATE OR REPLACE FUNCTION fn_etl_pozos_datos_tecnicos()
RETURNS TRIGGER AS
$$
BEGIN

    -- Diámetros > 30
    IF NEW.diametro_superior_in > 30 THEN
        NEW.diametro_superior_in := NULL;
    END IF;

    IF NEW.diametro_inferior_in > 30 THEN
        NEW.diametro_inferior_in := NULL;
    END IF;

    -- Regla telescópica
    IF NEW.diametro_superior_in IS NOT NULL
       AND NEW.diametro_inferior_in IS NOT NULL
       AND NEW.diametro_superior_in < NEW.diametro_inferior_in THEN
        NEW.diametro_superior_in := NULL;
        NEW.diametro_inferior_in := NULL;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para la nueva tabla de datos técnicos/físicos
DROP TRIGGER IF EXISTS trg_etl_pozos_datos_tecnicos ON pozos_datos_tecnicos;
CREATE TRIGGER trg_etl_pozos_datos_tecnicos
    BEFORE INSERT OR UPDATE ON pozos_datos_tecnicos
    FOR EACH ROW
    EXECUTE FUNCTION fn_etl_pozos_datos_tecnicos();