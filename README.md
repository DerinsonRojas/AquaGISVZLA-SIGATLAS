🌎 AquaGISVZLA — Plataforma Hidrogeoespacial de Pozos de Agua de Venezuela
Sistema moderno de ingeniería de datos, geoprocesamiento y análisis hidrogeoespacial
AquaGISVZLA es un sistema integral para la depuración, normalización, migración y visualización de registros históricos de pozos profundos de agua subterránea en Venezuela.
El proyecto moderniza una base de datos legacy del antiguo Ministerio del Ambiente (hasta 2006), utilizada durante décadas en:

tesis de pregrado y postgrado

estudios hidrogeológicos

planificación hídrica

investigaciones científicas

proyectos de gestión territorial

AquaGISVZLA reconstruye esta información mediante una arquitectura moderna basada en Python, PostgreSQL, PostGIS y QGIS, con proyección a mapas interactivos, análisis hidrogeológicos y futuros dashboards web.

🚀 Características Técnicas Principales
🧩 Pipeline ETL profesional (Python + Pandas)
Limpieza, normalización y estandarización de datos legacy.

Eliminación de duplicados y corrección de tipos.

Validación estricta de integridad referencial.

Nuevo patrón de carga masiva:  
STAGING → VALIDACIÓN → SWAP → VERIFICACIÓN  

🏗️ Modelo Relacional Modernizado
Separación física de atributos (pozos_master, pozos_quimica, pozos_litologia, pozos_nivel, datos_técnicos).

Claves primarias y foráneas activas.

Tablas _limpios y _huerfanos para trazabilidad.

Integridad relacional garantizada.

🌐 Geoprocesamiento Avanzado (PostGIS)
Interpretación del datum legacy La Canoa (PSAD56 UTM).

Transformación precisa a WGS84 (EPSG:4326).

Corrección de desplazamientos históricos.

Generación de geometrías compatibles con QGIS.

Calculo de altitud de cada pozo con ubicación a partir de imagen mosaico NASADEM de Venezuela

🗺️ Vista espacial oficial
v_pozos_wgs84_dd_qgis (Óptimizda en gradOs decimales para mayor rendimiento en QGIS o visores web).

Compatible con QGIS y visores web.

⚙️ Automatización del flujo
ETL modular por fases.

Validaciones automáticas en staging.

Swap atómico para cargas masivas.

Funciones y triggers PL/pgSQL para reglas de negocio.

📚 Documentación técnica profesional
Incluye:

arquitectura SIG

justificación del modelo relacional

estándares de nombres

justificación de vistas espaciales

manual de ETL

libro blanco del sistema

🛠️ Stack Tecnológico
Tecnología	Uso
Python 3.x	Pipeline ETL
Pandas	Limpieza y transformación
PostgreSQL + PostGIS	Base de datos relacional y espacial
QGIS	Visualización geoespacial
Git / GitHub	Control de versiones
AquaGISVZLA	Sistema hidrogeoespacial


📁 Estructura del Repositorio
Código
SIGATLASV1/
│
├── BBDD_SIGATLAS/            # Base de datos legacy (Access)
├── DATOS_ORIGINALES/         # Archivos fuente sin procesar
├── DATOS_PROCESADOS/         # Resultados del ETL (CSV limpios)
│
├── DOCUMENTACION/
│   ├── 00_INDICE_GENERAL.md
│   ├── ARQUITECTURA_SIG.md
│   ├── JUSTIFICACION_MODELO_TABLAS.md
│   ├── JUSTIFICACION_MODELO_VISTAS.md
│   ├── ESTANDARES_NOMBRES_TABLAS.md
│   ├── ESTANDARES_NOMBRE_VISTAS_SIG.md
│   └── AquaGISVZLA.md
│
├── ETL_PYTHON/
│   ├── POZOS_MASTER/
│   │   └── ETL_FASE_4_POZOS_MASTER.py
│   ├── POZOS_QUIMICA/
│   │   └── ETL_FASE_3_POZOS_QUIMICA.py
│   ├── POZOS_LITOLOGIA/
│   │   └── ETL_FASE_2_POZOS_LITOLOGIA.py
│   └── POZOS_NIVEL/
│   │   └── ETL_FASE_2_POZOS_NIVEL.py
│   └──── POZOS_DATOS_TECNICOS/
│       └── ETL_FASE_2_POZOS_DATOS_TECNICOS.py
│
├── GEOESPACIAL/              # Scripts PostGIS, vistas y funciones espaciales
│
├── SQL_CONSULTAS/
│   ├── LITOLOGIA/
│   ├── MASTER/
│   ├── POSTGRES_TO_QGIS/
│   └── QUIMICA/
│   ├── DATOS_TECNICOS/
│   └── NIVEL/
│
└── .gitignore
🔁 Nuevo Flujo de Trabajo (sin TRUNCATE)
Código
1️⃣ Actualizar funciones PL/pgSQL (si hay nuevas reglas)

2️⃣ Ejecutar ETL con el patrón profesional:
    STAGING → VALIDACIÓN → SWAP → VERIFICACIÓN

3️⃣ Verificar la vista espacial en QGIS
    v_pozos_geometria_auditoria_ubicacion_qgis (esta vista se proyecta con las UTM obtenidas de las coordenadas norte este de cada pozo)

4️⃣ Validar integridad relacional
    PK–FK, huérfanos, duplicados, geometrías

5️⃣ Commit + Push al repositorio

🧭 Origen de la Data Legacy
La base original proviene del Ministerio del Ambiente de Venezuela, responsable de la gestión hídrica y ambiental del país hasta 2006.
El repositorio rescata más de 15.000 registros de pozos profundos, utilizados históricamente en estudios académicos y técnicos.

AquaGISVZLA moderniza esta información para garantizar su preservación y reutilización en nuevos trabajos.

📊 Estado Actual del Proyecto
Modelo relacional completamente enlazado

Tablas _limpios y _huerfanos estabilizadas

Vista espacial oficial corregida y validada

ETL modular por fases

Documentación técnica completa

ETL refactorizado sin TRUNCATE

Arquitectura lista para visor web profesional

Próximas etapas:
Depuración espacial avanzada en QGIS

Integración litológica y análisis estratigráfico

Generación de mapas interactivos

Publicación de dashboards web

🎓 Proyección Académica
AquaGISVZLA servirá como base para:

trabajos de investigación

tesis de grado

proyectos hidrogeológicos

análisis SIG avanzados

Máster en Sistemas de Información Geográfica (UNIGIS – Universitat de Girona)

👤 Autor
Derinson Rojas  
Ingeniero Geólogo | SIG & ETL Developer
Proyecto AquaGISVZLA — Modernización hidrogeoespacial de Venezuela.

🗂️ Nota sobre la estructura del proyecto
El directorio principal mantiene el nombre SIGATLASV1 por motivos de compatibilidad técnica y preservación de rutas internas utilizadas en:

scripts ETL

consultas SQL

configuraciones de QGIS

Aunque el nombre oficial del sistema es AquaGISVZLA, se conserva la denominación original para garantizar estabilidad y trazabilidad histórica.