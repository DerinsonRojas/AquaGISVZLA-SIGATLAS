AquaGISVZLA: Plataforma Hidrogeoespacial de Pozos de Agua de Venezuela
📌 Descripción del Proyecto
AquaGISVZLA es un sistema moderno de ingeniería de datos y análisis hidrogeoespacial diseñado para la limpieza, normalización, migración, depuración y visualización de registros históricos de pozos profundos de agua subterránea en Venezuela.

El proyecto reconstruye y moderniza una base de datos legacy generada por el antiguo Ministerio del Ambiente de Venezuela (institución activa hasta 2006), utilizada durante décadas en:

tesis de pregrado y postgrado,

estudios hidrogeológicos,

planificación hídrica,

investigaciones científicas,

proyectos de gestión territorial.

AquaGISVZLA rescata, depura y transforma esta información mediante una arquitectura moderna basada en Python, PostgreSQL, PostGIS y QGIS, con proyección a mapas interactivos, análisis hidrogeológicos y dashboards web.

🚀 Características Técnicas
Pipeline ETL completo (Python + Pandas):  
Limpieza, normalización, eliminación de duplicados, corrección de tipos y estandarización de coordenadas.

Modelo Relacional Modernizado:  
Separación física de atributos (pozos_fisicos), claves foráneas activas, entidades _limpios y _huerfanos para trazabilidad.

Geoprocesamiento avanzado (PostGIS):  
Interpretación del datum legacy La Canoa (PSAD56 UTM) y transformación precisa a WGS84 (EPSG:4326).

Vista espacial oficial:  
v_pozos_geometria_corregidaWGS84_qgis  
Corrige desplazamientos históricos y garantiza compatibilidad total con QGIS.

Automatización del flujo:  
Carga mediante TRUNCATE + APPEND, con normalización automática vía triggers y funciones PL/pgSQL.

Documentación técnica profesional:  
Estándares, justificaciones, arquitectura SIG y versión del modelo relacional.

🛠️ Stack Tecnológico
Tecnología	Uso
Python 3.x	Pipeline ETL
Pandas	Limpieza y transformación
PostgreSQL + PostGIS	Base de datos relacional y espacial
QGIS	Visualización geoespacial
Git / GitHub	Control de versiones
AquaGISVZLA	Sistema hidrogeoespacial


📂 Estructura del Repositorio
plaintext
SIGATLASV1/
│
├── 📁 BBDD_SIGATLAS/           → Base de datos legacy (Access)
├── 📁 DATOS_ORIGINALES/        → Archivos fuente sin procesar
├── 📁 DATOS_PROCESADOS/        → Resultados del ETL (CSV limpios)
│
├── 📁 DOCUMENTACION/           → Documentación técnica del sistema
│   ├── 00_INDICE_GENERAL.md    → Índice central de navegación
│   ├── ARQUITECTURA_SIG.md
│   ├── JUSTIFICACION_MODELO_TABLAS.md
│   ├── JUSTIFICACION_MODELO_VISTAS.md
│   ├── ESTANDARES_NOMBRES_TABLAS.md
│   ├── ESTANDARES_NOMBRE_VISTAS_SIG.md
│   └── AquaGISVZLA.md          → Diagrama ER
│
├── 📁 ETL_PYTHON/              → Scripts ETL por dominio
│   ├── POZOS_NIVEL/
│   │   └── ETL_FASE_1_POZOS_NIVEL.py
│   ├── POZOS_LITOLOGIA/
│   │   └── ETL_FASE_1_POZOS_LITOLOGIA.py
│   ├── POZOS_MASTER/
│   │   └── ETL_FASE_2_POZOS_MASTER.py
│   └── POZOS_QUIMICA/
│       └── ETL_FASE_2_POZOS_QUIMICA.py
│
├── 📁 GEOESPACIAL/             → Scripts PostGIS, vistas y funciones espaciales
│
├── 📁 SQL_CONSULTAS/           → Consultas SQL organizadas por módulo
│   ├── LITOLOGIA/
│   ├── MASTER/
│   ├── POSTGRES_TO_QGIS/
│   └── QUIMICA/
│
└── .gitignore
🔁 Flujo de Trabajo
Actualizar funciones PL/pgSQL (si hay nuevas reglas).

Ejecutar ETL (TRUNCATE + APPEND) para cargar datos limpios.

Verificar la vista espacial en QGIS (v_pozos_geometria_corregidaWGS84_qgis).

Validar integridad relacional (huérfanos, claves foráneas).

Commit + Push al repositorio.

🧭 Origen de la Data Legacy
La base de datos original proviene del Ministerio del Ambiente de Venezuela, responsable de la gestión hídrica y ambiental del país hasta 2006.

Este repositorio rescata más de 15.000 registros de pozos profundos, utilizados históricamente en:

tesis de pregrado y postgrado,

estudios hidrogeológicos,

planificación hídrica,

investigaciones científicas,

proyectos de gestión territorial.

AquaGISVZLA moderniza esta información para garantizar su preservación y reutilización en nuevos trabajos académicos y técnicos.

📊 Estado del Proyecto
El sistema se encuentra en fase de consolidación avanzada, con:

modelo relacional completamente enlazado,

tablas _limpios y _huerfanos estabilizadas,

vista espacial oficial corregida y validada,

ETL modular por fases,

documentación técnica completa.

Próximas etapas:
depuración espacial avanzada en QGIS (v1.6),

integración litológica y análisis estratigráfico,

análisis hidrogeoespacial avanzado,

generación de mapas interactivos,

publicación de dashboards web.

🗂️ Nota sobre la estructura del proyecto
El directorio principal del repositorio mantiene el nombre SIGATLASV1 por motivos de compatibilidad técnica y preservación de rutas internas utilizadas en los scripts ETL, consultas SQL y configuraciones de QGIS.
Aunque el nombre lógico y oficial del sistema es AquaGISVZLA, se conserva la denominación original para garantizar la estabilidad del entorno y la trazabilidad histórica del proyecto.

🎓 Proyección Académica
AquaGISVZLA servirá como base para futuros trabajos de investigación y como plataforma de análisis para el Máster en Sistemas de Información Geográfica (UNIGIS – Universitat de Girona) y otros programas académicos relacionados con hidrogeología y SIG.

🧩 Autor
Derinson Rojas  
Ingeniero Geólogo | SIG & ETL Developer
Proyecto AquaGISVZLA — Modernización hidrogeoespacial de Venezuela.