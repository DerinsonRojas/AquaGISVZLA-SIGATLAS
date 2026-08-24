--FUNCIÓN PARA LA REVISIÓN Y VALIDACIÓN DE DATOS INMEDIATA A LA CARGA 
-- 1. Añadimos las dos columnas nuevas a la tabla física (si no existen ya)
-- Si se migra la BBDD hay que crear estas columnas en pgAdmin, luego se ejecuta la función
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
	-- ============================================================
    --  DUREZA TOTAL (Recálculo y Corrección)
    -- ============================================================
   
    -- PASO 1: LIMPIEZA ABSOLUTA DE PARAMETROS INDIVIDUALES
    -- Si al cargar el ETL no existiera dtotal, crearlo en pgAdmin
    -- (Convertir Ceros a Nulos primero que todo)
     
    IF NEW.so4 < 0 THEN NEW.so4 := NULL; END IF;
    IF NEW.ca = 0  THEN NEW.ca  := NULL; END IF;
    IF NEW.mg = 0  THEN NEW.mg  := NULL; END IF;
    
    -- PASO 2: CÁLCULO Y LIMPIEZA DE DUREZA TOTAL 
    -- (Ocurre después de limpiar Ca y Mg)
    
    IF (NEW.dtotal IS NULL OR NEW.dtotal = 0) THEN
        IF (NEW.ca IS NOT NULL AND NEW.mg IS NOT NULL) THEN
            -- Se añade ::numeric para que ROUND no lance error con los double precision
            NEW.dtotal := ROUND(((2.497 * NEW.ca) + (4.118 * NEW.mg))::numeric, 2);
        ELSE
            NEW.dtotal := NULL;
        END IF;
    END IF;

    -- ============================================================
    --  FLUORUROS (Corrección de negativos, placeholders y outliers)
    -- ============================================================

    IF NEW.f IS NOT NULL THEN

        -- 1. Valores negativos o -1 → no físicos
        IF NEW.f < 0 OR NEW.f = -1 THEN
            NEW.f := NULL;

        -- 2. Placeholder sistemático del legacy
        ELSIF NEW.f = 11.11 THEN
            NEW.f := NULL;

        -- 3. Valores físicamente imposibles (> 50 mg/L)
        ELSIF NEW.f > 50 THEN
            NEW.f := NULL;

        -- 4. Valores sospechosos (> 20 mg/L)
        ELSIF NEW.f > 20 THEN
            NEW.f := NULL;

        END IF;

    END IF;

    -- ============================================================
    --  ALCALINIDAD (Corrección de ceros y outliers)
    -- ============================================================
    IF NEW.alc <= 0 THEN NEW.alc := NULL; END IF;

    -- ============================================================
    --  CLORUROS (Corrección de negativos)
    -- ============================================================
    IF NEW.cl < 0 THEN NEW.cl := NULL; END IF;

    -- ============================================================
    --  SOLIDOS TOTALES DISUELTOS (ceros y negativos a null)
    -- ============================================================

     IF NEW.tsd <= 10 THEN NEW.tsd := NULL; END IF;

    -- ============================================================
    --  RAS Relación de adsorción de sodio ( negativos a null)
    -- ============================================================

    -- ============================================================
    -- ESTADO RAS
    -- ============================================================

    -- 1. RAS nulo → sin clasificar
    IF NEW.ras IS NULL THEN
        NEW.estado_ras := 'SIN CLASIFICAR';

    -- 2. RAS negativo (incluye -1) → error
    ELSIF NEW.ras < 0 THEN
        NEW.estado_ras := 'ERROR';

    -- 3. RAS físicamente imposible
    ELSIF NEW.ras > 200 THEN
        NEW.estado_ras := 'ERROR';
        NEW.ras := NULL;

    -- 4. RAS sospechoso
    ELSIF NEW.ras > 40 AND NEW.ras <= 200 THEN
        NEW.estado_ras := 'SOSPECHOSO';

    -- 5. RAS válido
    ELSIF NEW.ras > 0 AND NEW.ras <= 40 THEN
        NEW.estado_ras := 'OK';

    -- 6. Caso especial: RAS = 0
    ELSIF NEW.ras = 0 THEN
        -- Si Na = 0 y Ca+Mg > 0 → SIN SODIO
        IF NEW.na = 0 AND (NEW.ca + NEW.mg) > 0 THEN
            NEW.estado_ras := 'SIN_SODIO';

        -- Si TSD > 1000 → INCONSISTENTE
        ELSIF NEW.tsd > 1000 THEN
            NEW.estado_ras := 'INCONSISTENTE';

        -- Si no cumple nada → OK (RAS=0 válido)
        ELSE
            NEW.estado_ras := 'OK';
        END IF;
    END IF;

    -- Retornamos la fila modificada con todos los campos procesados
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. Borramos triggers antiguos para evitar duplicidades o conflictos

DROP TRIGGER IF EXISTS trg_control_calidad_quimica ON public.pozos_quimica;

-- 4. Creamos el nuevo trigger unificado ligado a la tabla
CREATE TRIGGER trg_control_calidad_quimica
BEFORE INSERT OR UPDATE ON public.pozos_quimica
FOR EACH ROW
EXECUTE FUNCTION fn_limpiar_parametros_quimica();