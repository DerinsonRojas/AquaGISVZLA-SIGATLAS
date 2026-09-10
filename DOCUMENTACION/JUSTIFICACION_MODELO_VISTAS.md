🧭 JUSTIFICACIÓN DEL MODELO DE VISTAS — AquaGISVZLA
Fecha: 10 de septiembre de 2026
Autor: Derinson
Objetivo: Documentar la razón de ser, el propósito funcional y la lógica técnica detrás de cada vista del sistema AquaGISVZLA, tanto espaciales como analíticas y auxiliares.

🟩 1. Rol de las Vistas en el Modelo AquaGISVZLA
Las vistas cumplen tres funciones fundamentales dentro del sistema:

1.1. Estandarización SIG
Transforman coordenadas, corrigen geometrías y generan capas compatibles con QGIS sin alterar las tablas base.

1.2. Análisis químico y temporal
Organizan, clasifican y reordenan datos químicos para facilitar análisis hidroquímicos y validaciones.

1.3. Depuración y control
Permiten visualizar datos depurados, corregidos o reorganizados sin duplicar tablas ni romper el flujo ETL.

🟦 2. Justificación de las Vistas Espaciales (SIG)
2.1. v_pozos_geometria_corregidaWGS84_qgis
Problema que resuelve
Los pozos estaban originalmente en coordenadas planas PSAD56 UTM (La Canoa), con husos variables según estado.
QGIS requiere coordenadas geográficas WGS84 (EPSG:4326) para visualizar correctamente.

Por qué es una vista y no una tabla
La transformación es dinámica, no estática.

No se debe alterar la tabla base pozos_master.

Permite actualizar geometrías automáticamente si cambian coordenadas o estados.

Evita duplicar datos espaciales.

Lógica encapsulada
Construcción del punto UTM (ST_MakePoint).

Asignación del SRID correcto según estado y longitud.

Transformación a WGS84 (ST_Transform).

Validación de geometría.

Filtro de pozos con geometría válida.

Resultado
Una capa SIG lista para QGIS, Leaflet, GeoServer y análisis espacial.

🟩 3. Justificación de las Vistas Químicas
3.1. v_quimica_clasificacion_langelier_analisis
Problema que resuelve
El índice de Langelier requiere combinar pH, alcalinidad y dureza para clasificar el agua como:

corrosiva

equilibrada

incrustante

La tabla base no contiene esta clasificación.

Por qué es una vista
La clasificación es derivada, no debe almacenarse físicamente.

Permite recalcular dinámicamente si cambian los valores químicos.

Evita duplicar información y mantiene la tabla base limpia.

Lógica encapsulada
Cálculo del índice de Langelier.

Clasificación hidroquímica.

Preparación para análisis y visualización.

3.2. v_quimica_dt_alc_sulfatos_analisis
Problema que resuelve
Los análisis químicos requieren correlaciones entre alcalinidad y sulfatos.
La tabla base contiene los datos, pero no organizados para análisis directo.

Por qué es una vista
Permite reorganizar columnas sin alterar la tabla base.

Facilita análisis estadísticos y gráficos.

Evita crear tablas auxiliares innecesarias.

Lógica encapsulada
Selección de variables químicas clave.

Reordenamiento para análisis.

Preparación para vistas derivadas (gráficos, correlaciones).

🟦 4. Justificación de las Vistas Auxiliares
4.1. v_pozos_quimica_fechasordenadas
Problema que resuelve
La tabla química tiene fechas dispersas y columnas no ordenadas cronológicamente.

Por qué es una vista
Reordena columnas sin alterar la estructura original.

Facilita análisis temporal.

Permite visualización clara en QGIS y herramientas externas.

Lógica encapsulada
Ordenamiento de fechas.

Selección de columnas relevantes.

Preparación para análisis temporal.

🟩 5. Criterios Técnicos para Crear Vistas
✔ No duplicar datos
Las vistas deben evitar crear tablas derivadas innecesarias.

✔ Mantener la tabla base intacta
Las vistas encapsulan lógica sin alterar datos originales.

✔ Preparar datos para análisis
Las vistas deben facilitar:

SIG

análisis químico

validación

depuración

correlaciones

✔ Ser compatibles con QGIS
Las vistas espaciales deben:

tener SRID definido

usar WGS84

contener geometría válida

✔ Ser trazables y documentadas
Cada vista debe tener:

propósito

lógica

origen

destino

🟦 6. Próximas Vistas a Crear
6.1. auditoria_pozos_geometria
Para pozos sin geometría o con valores fuera de rango.

6.2. v_pozos_buffer_500m_qgis
Para análisis de proximidad.

6.3. v_pozos_densidad_municipal
Para análisis de densidad espacial.

⭐ Conclusión
Este documento explica por qué existen las vistas, qué problema resuelven y cómo encajan en la arquitectura del sistema AquaGISVZLA.
Es la pieza que completa la gobernanza técnica junto con:

estándares de tablas,

estándares de vistas,

justificación del modelo de tablas,

arquitectura SIG.