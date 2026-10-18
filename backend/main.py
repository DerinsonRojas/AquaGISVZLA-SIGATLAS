from fastapi import FastAPI
from crud import obtener_pozos
from geojson import pozos_to_geojson
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # o ["http://localhost:5173"]
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/pozos")
def get_pozos():
    data = obtener_pozos()
    return pozos_to_geojson(data)

