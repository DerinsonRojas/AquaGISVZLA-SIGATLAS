-- Trigger para la nueva tabla de datos técnicos/físicos
DROP TRIGGER IF EXISTS trg_etl_pozos_datos_tecnicos ON pozos_datos_tecnicos;
CREATE TRIGGER trg_etl_pozos_datos_tecnicos
    BEFORE INSERT OR UPDATE ON pozos_datos_tecnicos
    FOR EACH ROW
    EXECUTE FUNCTION fn_etl_pozos_datos_tecnicos();