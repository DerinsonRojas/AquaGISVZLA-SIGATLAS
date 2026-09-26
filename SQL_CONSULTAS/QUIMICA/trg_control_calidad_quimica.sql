-- Borramos triggers antiguos para evitar duplicidades o conflictos

DROP TRIGGER IF EXISTS trg_control_calidad_quimica ON public.pozos_quimica;

-- Creamos el nuevo trigger unificado ligado a la tabla
CREATE TRIGGER trg_control_calidad_quimica
BEFORE INSERT OR UPDATE ON public.pozos_quimica
FOR EACH ROW
EXECUTE FUNCTION fn_limpiar_parametros_quimica();