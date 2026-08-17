CREATE OR REPLACE TRIGGER trg_etl_pozos_master
BEFORE INSERT OR UPDATE ON public.pozos_master
FOR EACH ROW
EXECUTE FUNCTION fn_etl_pozos_master();