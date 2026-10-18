from fastapi import FastAPI
from crud import obtener_pozos
from geojson import pozos_to_geojson

app = FastAPI()

@app.get("/pozos")
def get_pozos():
    data = obtener_pozos()
    return pozos_to_geojson(data)
