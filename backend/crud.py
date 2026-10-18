from db import get_connection

def obtener_pozos():
    conn = get_connection()
    cur = conn.cursor()

    cur.execute("""
        SELECT 
            id_pozo,
            municipio,
            sitio,
            nombre,
            propietario,
            estado,
            auditoria_estado,
            latitud,
            longitud,
            norte_m,
            este_m,
            altitud_msnm,
            altitud_origen,
            lat_dd,
            lon_dd,
            tiene_quimica,
            tiene_litologia,
            tiene_niveles,
            tiene_datos_tecnicos,
            ST_AsGeoJSON(geom) AS geom_json
        FROM public.v_pozos_wgs84_dd_qgis
    """)

    data = cur.fetchall()
    cur.close()
    conn.close()
    return data
