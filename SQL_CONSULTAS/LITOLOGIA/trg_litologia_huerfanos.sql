--Limpieza inicial, no se volverá a ejecutar
DELETE FROM public.pozos_litologia
WHERE id_pozo NOT IN (
    SELECT id_pozo FROM public.pozos_master
);

--Trigger para limpiar de huerfanos en futuras inserciones

CREATE TRIGGER trg_litologia_huerfanos
BEFORE INSERT OR UPDATE ON public.pozos_litologia
FOR EACH ROW
EXECUTE FUNCTION limpiar_litologia_huerfanos();
