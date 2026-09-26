--Se crea esta función para clasificar la ubicación rela de los puntos de pozos en pozos_master
--Se llena la columna auditoria_estado, que mostrará visualmente donde esta el pozo en visores web indicando por colores la naturaleza del pozo
--Los pozos en amarillo o SIN ENTIDAD, son pozos que están bien ubicados, pero simplemente caen en sitios sujetos a disputas territoriales 
--entre entidades federales en Venezuela
--Los que se etiquetan COINCIDE son pozos sin problemas en su ubicación
--NO COINCIDE para pozos que realmente no coinciden
--FUERA DE LIMITES para todo pozo fuera del polígono de Venezuela del IVGSB 

CREATE OR REPLACE FUNCTION fn_actualizar_auditoria_estado()
RETURNS void AS
$$
BEGIN
    -- 1. Prioridad máxima: Pozos identificados fuera de los límites de Venezuela
    UPDATE pozos_master AS m
    SET auditoria_estado = 'fuera_de_venezuela'
    FROM v_pozos_fuera_de_venezuela AS f
    WHERE m.id_pozo = f.id_pozo;

    -- 2. Asignar el resultado de la comparación automatizada
    -- (Solo actualiza si el pozo está registrado en la vista de comparación)
    UPDATE pozos_master AS m
    SET auditoria_estado = c.comparacion -- Se llenará con 'SIN ENTIDAD', 'COINCIDE', o 'NO COINCIDE'
    FROM v_pozos_estado_comparacion_all_cases AS c
    WHERE m.id_pozo = c.id_pozo
      -- BLINDAJE: Evitamos sobrescribir los ajustes manuales complejos que ya hiciste a mano.
      -- (Puedes adaptar esta condición según cómo identifiques tus ajustes manuales en la base de datos, 
      -- por ejemplo, si los marcaste con un flag, o si simplemente excluyes los que ya tienen una etiqueta específica).
      AND (m.auditoria_estado IS NULL OR m.auditoria_estado NOT IN ('ajuste_manual', 'excepcion_limrofe'));

    RAISE NOTICE 'Proceso de auditoría de estado actualizado correctamente.';
END;
$$ LANGUAGE plpgsql;

--Llamado a la función

SELECT fn_actualizar_auditoria_estado();