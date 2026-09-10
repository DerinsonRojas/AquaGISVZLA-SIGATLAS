🧭 Estándar Oficial de Nombres para Vistas SIG — AquaGISVZLA
Este documento define las reglas formales para nombrar vistas espaciales y vistas auxiliares dentro del proyecto AquaGISVZLA, garantizando coherencia, claridad y compatibilidad con el modelo relacional y el flujo SIG.

El objetivo es evitar ambigüedades, especialmente en vistas que involucran transformaciones geodésicas, y asegurar que cualquier persona pueda identificar rápidamente:

la entidad principal,

el propósito de la vista,

el sistema de coordenadas final,

y el destino de uso (QGIS, ETL, análisis, validación).

🟦 1. Estructura general del nombre
Todas las vistas deben seguir esta estructura:

Código
v_<entidad>_<detalle>_<sistema>_<destino>
1.1. v_
Prefijo obligatorio que indica que se trata de una vista.

1.2. <entidad>
La tabla o concepto principal que representa:

pozos

litologia

nivel

quimica

fisicos

etc.

1.3. <detalle>
Describe la función o transformación aplicada:

geometria

geometria_corregida

validos

depurada

ubicacion_inconsistente

analisis

export

etc.

1.4. <sistema>
Indica el sistema de coordenadas final de la vista:

WGS84

REGVEN

SIRGAS

UTM18N

UTM19N

UTM20N

etc.

1.5. <destino>
Indica el propósito o consumidor final:

qgis

etl

analisis

validacion

export

🟩 2. Reglas obligatorias
✔ 2.1. Siempre indicar el sistema de coordenadas final
Especialmente en vistas SIG.
Ejemplo correcto:

Código
v_pozos_geometria_corregidaWGS84_qgis
✔ 2.2. Nunca incluir el datum original en el nombre
El datum La Canoa se usa solo en la técnica interna, no en el nombre.

✔ 2.3. Siempre indicar el destino
Evita vistas ambiguas como:

Código
v_pozos_wgs84
Debe ser:

Código
v_pozos_geometriaWGS84_qgis
✔ 2.4. Usar snake_case
Consistente con PostgreSQL.

✔ 2.5. Prefijo obligatorio: v_
🟦 3. Ejemplos correctos (basados en AquaGISVZLA)
✔ Vista espacial principal (actual)
Código
v_pozos_geometria_corregidaWGS84_qgis
✔ Vista para validar pozos mal ubicados
Código
v_pozos_ubicacion_inconsistente_qgis
✔ Vista para análisis hidrogeológico
Código
v_pozos_geometriaWGS84_analisis
✔ Vista para exportar a Python/ETL
Código
v_pozos_geometriaWGS84_etl
✔ Vista para ver pozos en su datum original (si se requiere)
Código
v_pozos_geometriaREGVEN_legacy
✔ Vista para depuración interna
Código
v_pozos_geometria_corregidaWGS84_validacion
🟥 4. Ejemplos incorrectos (a evitar)
❌ Usar “la_canoa” en el nombre
La vista final no está en La Canoa.

❌ Nombres ambiguos
Código
v_pozos_final
v_pozos_ok
v_pozos_corregidos
❌ No indicar el sistema de coordenadas
Código
v_pozos_geometria
❌ No indicar el destino
Código
v_pozos_wgs84
🟩 5. Justificación del estándar
Este estándar surge de la necesidad de:

evitar confusiones entre datum original y sistema final,

mantener claridad en vistas SIG complejas,

facilitar la lectura del modelo espacial,

permitir que QGIS identifique correctamente las capas,

y asegurar que el repositorio sea mantenible a largo plazo.

La vista actual v_pozos_geometria_corregidaWGS84_qgis cumple perfectamente este estándar.

EJEMPLO DE VISTA AUXILIAR
## v_pozos_quimica_fechasordenadas

**Descripción:**  
Vista auxiliar que reordena las columnas de la tabla pozos_quimica para mostrar las fechas de análisis junto a las fechas originales, facilitando la comparación temporal.

**Propósito:**  
Visualización rápida de fechas químicas en QGIS y validación de registros antiguos.

**Sistema final:**  
No aplica (vista no espacial).

**Destino:**  
QGIS / análisis químico.

**Notas:**  
- No altera datos.  
- Solo cambia el orden de columnas.  
- Puede eliminarse o reemplazarse por una vista más específica en futuras versiones.


⭐ Conclusión
Este estándar garantiza que todas las vistas SIG del proyecto AquaGISVZLA mantengan coherencia técnica, claridad conceptual y compatibilidad con QGIS, ETL y análisis hidrogeológico.

A partir de v1.5, todas las vistas nuevas deben seguir esta convención.