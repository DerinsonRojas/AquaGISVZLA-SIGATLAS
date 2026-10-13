📘 LIBRO BLANCO DEL MODELO RELACIONAL — AquaGISVZLA
Arquitectura de Datos Hidrogeoespacial para la Modernización de Pozos de Agua en Venezuela
🧭 1. Introducción
El presente documento constituye el Libro Blanco del Modelo Relacional del sistema hidrogeoespacial AquaGISVZLA, una plataforma moderna diseñada para la depuración, normalización, migración y análisis de registros históricos de pozos profundos de agua subterránea en Venezuela.
El objetivo del modelo relacional es:
reconstruir una base de datos legacy del antiguo Ministerio del Ambiente (hasta 2006)
garantizar integridad referencial estricta
separar entidades según criterios hidrogeológicos y SIG
habilitar análisis espaciales avanzados
permitir cargas masivas seguras y reproducibles
servir como base para visores web, dashboards y análisis académicos
Este documento describe la arquitectura conceptual, lógica y física del modelo, así como las decisiones de diseño que permiten que AquaGISVZLA sea un sistema robusto, escalable y científicamente confiable.
🧩 2. Principios de Diseño del Modelo Relacional
El modelo relacional de AquaGISVZLA se construye sobre los siguientes principios:
2.1. Integridad hidrogeoespacial
Cada pozo es una entidad georreferenciada con atributos físicos, técnicos, litológicos, químicos y de nivel.
La integridad espacial se garantiza mediante PostGIS.
2.2. Separación física de atributos
Los atributos se distribuyen en tablas especializadas:
pozos_master → entidad principal
pozos_quimica → calidad del agua
pozos_litologia → estratigrafía
pozos_nivel → series históricas de nivel
pozos_datos_tecnicos → atributos técnicos
2.3. Integridad referencial estricta
Todas las tablas hijas dependen de pozos_master mediante claves foráneas.
2.4. Trazabilidad de datos legacy
Se mantienen tablas:
_limpios
_huerfanos
para auditoría y control de calidad.
2.5. Compatibilidad SIG
El modelo está optimizado para:
QGIS
PostGIS
visores web
análisis hidrogeológicos
2.6. Cargas masivas seguras
El sistema utiliza:
STAGING → VALIDACIÓN → SWAP → VERIFICACIÓN
sin TRUNCATE, sin CASCADE, sin pérdida de integridad.
🏗️ 3. Arquitectura Conceptual
A nivel conceptual, el sistema se organiza en cinco entidades principales:
Código
Pozo (Entidad raíz)
│
├── Química del Agua
├── Litología
├── Nivel Estático Mensual
└── Datos Técnicos

Cada entidad representa un aspecto hidrogeológico distinto del pozo.
🧱 4. Arquitectura Lógica (Modelo Relacional)
4.1. Tabla principal: pozos_master
Contiene:
identificador único (id_pozo)
coordenadas legacy y corregidas
atributos físicos
propietario
estatus
fecha de actualización
geometría PostGIS
PK: id_pozo  
Relaciones:
1:N con química
1:N con litología
1:N con nivel
1:1 con datos técnicos
4.2. pozos_quimica
Registros de calidad del agua.
PK: (id_pozo, act_quimi)  
FK: id_pozo → pozos_master  
Relación: 1:N
Incluye:
pH
conductividad
alcalinidad
sólidos disueltos
aniones y cationes
metales
fecha de análisis
4.3. pozos_litologia
Estratigrafía del pozo.
PK: (id_pozo, desde, hasta)  
FK: id_pozo → pozos_master  
Relación: 1:N
Incluye:
profundidad inicial
profundidad final
litología
fecha de actualización
4.4. pozos_nivel
Series históricas de nivel estático mensual.
PK: (id_pozo, anio)  
FK: id_pozo → pozos_master  
Relación: 1:N
Incluye:
12 columnas mensuales
fecha de actualización
4.5. pozos_datos_tecnicos
Atributos técnicos del pozo.
PK: id_pozo  
FK: id_pozo → pozos_master  
Relación: 1:1
Incluye:
profundidad de perforación
entubado
nivel estático
nivel dinámico
gasto
diámetros
🌐 5. Arquitectura Espacial (PostGIS)
5.1. Geometría oficial
La geometría corregida se almacena en:
Código
geom_wgs84

5.2. Vista espacial oficial
Código
v_pozos_geometria_corregidaWGS84_qgis

Garantiza:
coordenadas en EPSG:4326
compatibilidad con QGIS
corrección de desplazamientos legacy
trazabilidad de origen y destino
🔁 6. Arquitectura de Carga Masiva (ETL)
El sistema utiliza un patrón profesional:
Código
STAGING → VALIDACIÓN → SWAP → VERIFICACIÓN

6.1. Tabla staging
Cada tabla tiene su equivalente:
Código
pozos_master_stg
pozos_quimica_stg
pozos_litologia_stg
pozos_nivel_stg
pozos_datos_tecnicos_stg

6.2. Validaciones
PK duplicados
FK válidas
tipos correctos
fechas válidas
geometrías válidas
6.3. Swap atómico
Reemplaza la tabla de producción sin pérdida de integridad.
6.4. Verificación
conteos
vistas
integridad relacional
triggers activos
🛡️ 7. Integridad Relacional y Auditoría
7.1. Claves primarias
Garantizan unicidad y trazabilidad.
7.2. Claves foráneas
Evitan huérfanos y aseguran consistencia.
7.3. Tablas _huerfanos
Permiten auditoría de datos legacy.
7.4. Triggers PL/pgSQL
Aplican reglas de negocio:
normalización
estandarización
validación técnica
control de calidad
📊 8. Justificación del Modelo
8.1. Separación por dominios hidrogeológicos
Cada tabla representa un dominio conceptual distinto.
8.2. Escalabilidad
Permite:
dashboards
visores web
análisis avanzados
integración con SIG institucionales
8.3. Reproducibilidad
El sistema puede reconstruirse en cualquier máquina mediante:
dump binario
ETL refactorizado
vistas espaciales
8.4. Compatibilidad académica
El modelo sigue estándares SIG internacionales.
🧪 9. Validación del Modelo
El modelo ha sido validado mediante:
auditorías de integridad
pruebas de carga masiva
verificación espacial en QGIS
análisis hidrogeológicos preliminares
revisión de duplicados y huérfanos
🎯 10. Conclusiones
El modelo relacional de AquaGISVZLA:
moderniza una base legacy crítica para Venezuela
garantiza integridad hidrogeoespacial
habilita análisis avanzados
es reproducible y escalable
está listo para visores web y dashboards
cumple estándares SIG profesionales
preserva la trazabilidad histórica de los datos
Este Libro Blanco constituye la referencia oficial para el diseño, mantenimiento y evolución del sistema.
👤 Autor
Derinson Rojas  
Ingeniero Geólogo | SIG & ETL Developer
Proyecto AquaGISVZLA — Modernización hidrogeoespacial de Venezuela.
