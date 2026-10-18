import json

def pozos_to_geojson(rows):
    features = []

    for r in rows:
        geom = json.loads(r[-1])  # geom_json es el último campo

        properties = {
            "id_pozo": r[0],
            "municipio": r[1],
            "sitio": r[2],
            "nombre": r[3],
            "propietario": r[4],
            "estado": r[5],
            "auditoria_estado": r[6],
            "latitud": r[7],
            "longitud": r[8],
            "norte_m": r[9],
            "este_m": r[10],
            "altitud_msnm": r[11],
            "altitud_origen": r[12],
            "lat_dd": r[13],
            "lon_dd": r[14],
            "tiene_quimica": r[15],
            "tiene_litologia": r[16],
            "tiene_niveles": r[17],
            "tiene_datos_tecnicos": r[18]
        }

        features.append({
            "type": "Feature",
            "geometry": geom,
            "properties": properties
        })

    return {
        "type": "FeatureCollection",
        "features": features
    }
