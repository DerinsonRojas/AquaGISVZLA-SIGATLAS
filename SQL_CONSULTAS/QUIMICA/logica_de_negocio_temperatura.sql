-- ============================================================
-- 1. LIMPIEZA INICIAL DE DATOS HISTÓRICOS
-- ============================================================
UPDATE public.pozos_quimica 
SET temperatura_c = NULL 
WHERE temperatura_c = 0;

-- ============================================================
-- 2. FUNCIÓN DE LIMPIEZA AUTOMÁTICA
-- ============================================================
CREATE OR REPLACE FUNCTION fn_limpiar_temperatura_cero()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.temperatura_c = 0 THEN
        NEW.temperatura_c := NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- 3. TRIGGER (DISPARADOR) AUTOMÁTICO
-- ============================================================
DROP TRIGGER IF EXISTS trg_limpiar_temp_cero ON public.pozos_quimica;

CREATE TRIGGER trg_limpiar_temp_cero
BEFORE INSERT OR UPDATE ON public.pozos_quimica
FOR EACH ROW
EXECUTE FUNCTION fn_limpiar_temperatura_cero();   