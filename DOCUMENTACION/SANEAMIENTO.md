# 🧭 Saneamiento Geográfico — AquaGISVZLA

## Objetivo
Documentar el proceso de depuración y auditoría espacial aplicado a la base de datos nacional de pozos, garantizando coherencia geométrica y territorial.

## 1. Contexto
El saneamiento se realizó sobre la tabla `pozos_master` y las vistas espaciales derivadas, con el propósito de eliminar inconsistencias y validar coordenadas.

## 2. Acciones principales
- Creación del campo auditoria_estado en pozos_master
auditoria_estado       --Permite clasificar los pozos según su calidad de ubicación y clasificación en QGIS
                        --('OK' Para los que estan bien)
                       -- 'NO_COINCIDE_LIMITROFE' Pozos con nombre diferente a su ubicación pero en zona limitrofe, se toman como buenos
                       -- 'NO_COINCIDE_REAL' Pozos que tienen se ubican muy lejos de donde indica su id_pozo
                       -- 'FUERA_DE_VENEZUELA' Pozos que intersectados con el shapefile de Venezuela quedan completamente fuera del territorio nacional / Algunos de los pozos fuera son útiles pero hay que revisar cada caso puntualmente
- Eliminación de etiquetas espaciales en pozos sin geometría (`auditoria_estado = NULL`).
- Recuperación de pozos con coordenadas verificables (ej. `GU5357006N`)
-Recuperación de pozo por su información de sitio (`FA6678008A`).
- Sincronización total entre `pozos_master` y `v_pozos_wgs84_auditoria_ubicacion_qgis`.
- Creación del proyecto QGIS **AQUAGIS_WGS84_DEPURADO**.

## 3. Resultados finales
| Clasificación | Descripción | Cantidad |
|---------------|--------------|-----------|
| OK | Pozos correctamente ubicados | 13.904 |
| NO_COINCIDE_LIMITROFE | Discrepancia menor | 117 |
| NO_COINCIDE_REAL | Discrepancia significativa | 48 |
| FUERA_DE_VENEZUELA | Ubicados fuera del polígono nacional | 100 |
| NULL | Sin geometría / no auditables | 1.263 |

## 4. Impacto en la arquitectura
El saneamiento no modifica la estructura del sistema, pero garantiza que las vistas espaciales operen sobre datos coherentes y auditables.

## 5. Próximos pasos
- Generar vistas derivadas para análisis SIG (buffers, densidad, intersecciones).