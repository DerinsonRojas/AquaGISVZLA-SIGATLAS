--La siguiente vista tiene como objetivo el analisis de los parametros químicos, 
--además de la fecha de análisis validada y estandarizada,
 --y el estado asociado a la validación (OK, error, sospechoso).
 --Para una colsulta de fecha de análisis, siempre usar fecha_analisis.

CREATE OR REPLACE VIEW vista_pozos_quimica AS
SELECT
    id_pozo,
    fecha,             -- campo legacy del sistema original
    fecha_analisis,    -- fecha validada y estandarizada
    estado_fecha,      -- estado asociado a la validación (OK, error, sospechoso)
    temperatura_c,
    ph,
    indice,
    conductividad_us_cm,
    alc,
    dtotal,
    tsd,
    ras,
    estado_ras,
    cl,
    so4,
    f,
    no2,
    no3,
    sio2,
    hco3,
    co3,
    fe,
    mn,
    b,
    duca,
    ca,
    mg,
    na,
    k,
    cu,
    zn,
    pb,
    po4,
    act_quimi
FROM pozos_quimica;
