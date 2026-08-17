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

    -- Diámetros > 30
    IF NEW.diametro_superior_in > 30 THEN
        NEW.diametro_superior_in := NULL;
    END IF;

    IF NEW.diametro_inferior_in > 30 THEN
        NEW.diametro_inferior_in := NULL;
    END IF;

    -- Regla telescópica
    IF NEW.diametro_superior_in IS NOT NULL
       AND NEW.diametro_inferior_in IS NOT NULL
       AND NEW.diametro_superior_in < NEW.diametro_inferior_in THEN
        NEW.diametro_superior_in := NULL;
        NEW.diametro_inferior_in := NULL;
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

    -- tiene_geometria
    NEW.tiene_geometria := (
        (NEW.latitud IS NOT NULL AND NEW.longitud IS NOT NULL)
        OR
        (NEW.norte_m IS NOT NULL AND NEW.este_m IS NOT NULL)
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
