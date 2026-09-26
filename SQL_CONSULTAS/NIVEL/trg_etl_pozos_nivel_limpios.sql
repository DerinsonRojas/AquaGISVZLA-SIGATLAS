CREATE TRIGGER trg_limpiar_nivel
BEFORE INSERT OR UPDATE ON public.pozos_nivel
FOR EACH ROW
EXECUTE FUNCTION limpiar_nivel();

