from pydantic import BaseModel
from typing import Optional

class Pozo(BaseModel):
    id_pozo: str
    municipio: Optional[int]
    sitio: Optional[str]
    nombre: Optional[str]
    propietario: Optional[str]
    estado: Optional[str]
    auditoria_estado: Optional[str]

    latitud: Optional[float]
    longitud: Optional[float]
    norte_m: Optional[float]
    este_m: Optional[float]

    altitud_msnm: Optional[float]
    altitud_origen: Optional[str]

    lat_dd: float
    lon_dd: float

    tiene_quimica: bool
    tiene_litologia: bool
    tiene_niveles: bool
    tiene_datos_tecnicos: bool
