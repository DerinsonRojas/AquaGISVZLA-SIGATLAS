CREATE OR REPLACE FUNCTION fn_etl_pozos_master()
RETURNS TRIGGER AS
$$
BEGIN

    -- Normalización ind_bombeo
    IF NEW.ind_bombeo IS NOT NULL THEN
        IF NEW.ind_bombeo IN ('SI','X') THEN
            NEW.ind_bombeo := TRUE;
        ELSIF NEW.ind_bombeo IN ('NO','0') THEN
            NEW.ind_bombeo := FALSE;
        ELSE
            NEW.ind_bombeo := NULL;
        END IF;
    END IF;

    -- Normalización ind_registro
    IF NEW.ind_registro IS NOT NULL THEN
        IF NEW.ind_registro IN ('SI','S','X') THEN
            NEW.ind_registro := TRUE;
        ELSIF NEW.ind_registro IN ('NO','0') THEN
            NEW.ind_registro := FALSE;
        ELSE
            NEW.ind_registro := NULL;
        END IF;
    END IF;

    -- Normalización de estatus
    IF NEW.cod_estatus_pozo IS NOT NULL THEN
        NEW.cod_estatus_pozo := UPPER(NEW.cod_estatus_pozo);
    END IF;

    -- estado_codigo = primeros 2 caracteres del ID
    NEW.estado_codigo := LEFT(NEW.id_pozo, 2);

    -- estado (mapeo completo)
    CASE NEW.estado_codigo
        WHEN 'ZU' THEN NEW.estado := 'ZULIA';
        WHEN 'AN' THEN NEW.estado := 'ANZOATEGUI';
        WHEN 'FA' THEN NEW.estado := 'FALCON';
        WHEN 'BA' THEN NEW.estado := 'BARINAS';
        WHEN 'MO' THEN NEW.estado := 'MONAGAS';
        WHEN 'GU' THEN NEW.estado := 'GUARICO';
        WHEN 'BO' THEN NEW.estado := 'BOLIVAR';
        WHEN 'TA' THEN NEW.estado := 'TACHIRA';
        WHEN 'ME' THEN NEW.estado := 'MERIDA';
        WHEN 'TR' THEN NEW.estado := 'TRUJILLO';
        WHEN 'LA' THEN NEW.estado := 'LARA';
        WHEN 'PO' THEN NEW.estado := 'PORTUGUESA';
        WHEN 'SU' THEN NEW.estado := 'SUCRE';
        WHEN 'DA' THEN NEW.estado := 'DELTA AMACURO';
        WHEN 'AM' THEN NEW.estado := 'AMAZONAS';
        WHEN 'AP' THEN NEW.estado := 'APURE';
        WHEN 'MI' THEN NEW.estado := 'MIRANDA';
        WHEN 'YA' THEN NEW.estado := 'YARACUY';
        WHEN 'NE' THEN NEW.estado := 'NUEVA ESPARTA';
        WHEN 'CO' THEN NEW.estado := 'COJEDES';
        WHEN 'AR' THEN NEW.estado := 'ARAGUA';
        WHEN 'CA' THEN NEW.estado := 'CARABOBO';
        WHEN 'VA' THEN NEW.estado := 'LA GUAIRA';
        WHEN 'DF' THEN NEW.estado := 'DISTRITO CAPITAL';
        WHEN 'ZZ' THEN NEW.estado := 'POR DETERMINAR';
        ELSE NEW.estado := 'DESCONOCIDO';
    END CASE;

    /*-- tiene_geometria
    NEW.tiene_geometria := (
        (NEW.latitud IS NOT NULL AND NEW.longitud IS NOT NULL)
        OR
        (NEW.norte_m IS NOT NULL AND NEW.este_m IS NOT NULL)
    );*/

--  Evaluación de geometría completa (norte_m y este_m, o latitud y longitud)
    NEW.tiene_geometria := (
        (NEW.latitud IS NOT NULL AND NEW.longitud IS NOT NULL)
        OR
        (NEW.norte_m IS NOT NULL AND NEW.este_m IS NOT NULL)
    );
-- 6. Lógica separada y limpia de altitud y origen
    IF NEW.altitud_msnm IS NOT NULL THEN
        -- CASO 1: El registro YA tenía su altitud original. Se respeta 100%.
        NEW.altitud_origen := 'original';
    ELSE
        -- CASO 2: El registro está VACÍO. Intentamos rellenarlo desde la tabla de validados.
        IF NEW.tiene_geometria = TRUE THEN
            SELECT altitud1 INTO NEW.altitud_msnm
            FROM pozos_con_altitud_wgs84_validados
            WHERE id_pozo = NEW.id_pozo
              AND altitud1 IS NOT NULL;
        END IF;

        -- Comprobamos si se logró rellenar o no
        IF NEW.altitud_msnm IS NOT NULL THEN
            -- Se rellenó gracias al proceso de validación/modelo
            NEW.altitud_origen := 'nasadem';
        ELSE
            -- No vino original y tampoco se encontró en validados
            NEW.altitud_msnm := NULL;
            NEW.altitud_origen := 'sin_dato';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;