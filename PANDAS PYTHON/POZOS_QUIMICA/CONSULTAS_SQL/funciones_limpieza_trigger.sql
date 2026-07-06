--FUNCIÓN PARA LA REVISIÓN Y VALIDACIÓN DE DATOS INMEDIATA A LA CARGA 
-- 1. Añadimos las dos columnas nuevas a la tabla física (si no existen ya)
ALTER TABLE public.pozos_quimica 
ADD COLUMN IF NOT EXISTS fecha_analisis DATE,
ADD COLUMN IF NOT EXISTS estado_fecha VARCHAR(20);

-- 2. Creamos o actualizamos la función unificada de control de calidad
CREATE OR REPLACE FUNCTION fn_limpiar_parametros_quimica()
RETURNS TRIGGER AS $$
DECLARE
    fecha_convertida DATE;
BEGIN
    -- ============================================================
    -- LOGICA PARA LA TEMPERATURA
    -- ============================================================
    IF NEW.temperatura_c = 0 THEN
        NEW.temperatura_c := NULL;
    END IF;

    -- ============================================================
    -- LÓGICA PARA LA ALCALINIDAD
    -- ============================================================
    IF NEW.alc = -1 OR NEW.alc > 1500 THEN
        NEW.alc := NULL;
    END IF;

    -- ============================================================
    -- LÓGICA PARA EL pH
    -- ============================================================
    IF NEW.ph IS NOT NULL THEN
        IF NEW.ph < 0 OR NEW.ph > 14 THEN
            NEW.ph := NULL;
        ELSIF NEW.ph < 4 OR NEW.ph > 10 THEN
            NEW.ph := NULL;
        END IF;
    END IF;

    -- ============================================================
    -- LÓGICA PARA LAS FECHAS
    -- ============================================================
  -- ============================================================
    -- LÓGICA PARA LAS FECHAS (Regex Corregida)
    -- ============================================================
    -- El día va de 01 a 31: (0[1-9]|[1-2][0-9]|3[0-1])
    -- El mes va de 01 a 12: (0[1-9]|1[0-2])
    -- El año son dos dígitos: [0-9]{2}
    
    IF NEW.fecha IS NOT NULL 
       AND NEW.fecha ~ '^(0[1-9]|[1-2][0-9]|3[0-1])(0[1-9]|1[0-2])[0-9]{2}$' THEN
        
        fecha_convertida := TO_DATE(NEW.fecha, 'DDMMYY');
        
        IF EXTRACT(YEAR FROM fecha_convertida) > 2026 THEN
            NEW.fecha_analisis := fecha_convertida - INTERVAL '100 years';
        ELSE
            NEW.fecha_analisis := fecha_convertida;
        END IF;
        
        NEW.estado_fecha := 'VALIDA';
    ELSE
        NEW.fecha_analisis := NULL;
        NEW.estado_fecha   := 'INCERTIDUMBRE';
    END IF;
-- ============================================================
    -- LÓGICA PARA LA CONDUCTIVIDAD
    -- ============================================================
    -- Si la conductividad es negativa, la transformamos en NULL
    IF NEW.conductividad_us_cm IS NOT NULL AND NEW.conductividad_us_cm < 0 THEN
        NEW.conductividad_us_cm := NULL;
    END IF;
	
    -- Retornamos la fila modificada con todos los campos procesados
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. Borramos triggers antiguos para evitar duplicidades o conflictos
DROP TRIGGER IF EXISTS trg_limpiar_temp_cero ON public.pozos_quimica;
DROP TRIGGER IF EXISTS trg_control_calidad_quimica ON public.pozos_quimica;

-- 4. Creamos el nuevo trigger unificado ligado a la tabla
CREATE TRIGGER trg_control_calidad_quimica
BEFORE INSERT OR UPDATE ON public.pozos_quimica
FOR EACH ROW
EXECUTE FUNCTION fn_limpiar_parametros_quimica();