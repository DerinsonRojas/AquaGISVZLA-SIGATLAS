# AquaGISVZLA: Plataforma Hidrogeoespacial de Pozos de Agua de Venezuela

## 📌 Descripción del Proyecto
**AquaGISVZLA** es un sistema moderno de ingeniería de datos y análisis hidrogeoespacial diseñado para la **limpieza, normalización, migración y visualización** de registros históricos de **pozos profundos de agua subterránea en Venezuela**.

Este proyecto reconstruye y moderniza una base de datos legacy generada originalmente por el **antiguo Ministerio del Ambiente de Venezuela** (institución activa hasta 2006), cuyos registros fueron utilizados durante décadas en **tesis de pregrado, postgrado, estudios hidrogeológicos y planificación hídrica nacional**.

AquaGISVZLA rescata, depura y transforma esta información para devolverla al ámbito académico y técnico mediante una arquitectura moderna basada en **Python, PostgreSQL, PostGIS y QGIS**, con proyección a **mapas interactivos y análisis avanzados**.

---

## 🚀 Características Técnicas

- **Pipeline ETL completo (Python + Pandas):**  
  Limpieza, normalización, eliminación de duplicados, corrección de tipos y estandarización de coordenadas.

- **Migración Relacional a PostgreSQL/PostGIS:**  
  Diseño de tablas optimizadas, triggers automáticos y funciones PL/pgSQL para aplicar reglas de negocio.

- **Geoprocesamiento avanzado:**  
  Generación de geometrías UTM → WGS84, vistas espaciales y compatibilidad total con QGIS.

- **Automatización del flujo:**  
  Carga mediante TRUNCATE + APPEND, con normalización automática vía triggers.

- **Proyección a mapas interactivos:**  
  Base sólida para futuros dashboards web, análisis hidrogeológicos y visualización dinámica.

---

## 🛠️ Stack Tecnológico

| Tecnología | Uso |
|-----------|-----|
| **Python 3.x** | Pipeline ETL |
| **Pandas** | Limpieza y transformación |
| **PostgreSQL + PostGIS** | Base de datos relacional y espacial |
| **QGIS** | Visualización geoespacial |
| **Git / GitHub** | Control de versiones |
| **AquaGISVZLA** | Nombre oficial del sistema |

---

## 📂 Estructura del Repositorio

```plaintext
AquaGISVZLA/
│
├── 📁 BBDD_SIGATLAS/           → Base de datos legacy (Access)
├── 📁 DATOS_ORIGINALES/        → Archivos fuente sin procesar
├── 📁 DATOS_PROCESADOS/        → Resultados del ETL (CSV limpios)
│
├── 📁 DOCUMENTACION/           → Documentos técnicos
│   ├── README.md
│   └── VERSIONES.md
│
├── 📁 ETL_PYTHON/              → Scripts ETL por dominio
│   ├── POZO_NIVEL/
│   ├── POZOS_MASTER/
│   └── POZOS_QUIMICA/
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

Verificar la vista espacial en QGIS (v_pozos_lacanoa).

Commit + Push al repositorio.

🧭 Origen de la Data Legacy
La base de datos original fue generada por el Ministerio del Ambiente de Venezuela, institución responsable de la gestión hídrica y ambiental del país hasta 2006.
Este repositorio rescata más de 15.000 registros de pozos profundos, utilizados históricamente en:

tesis de pregrado y postgrado,

estudios hidrogeológicos,

planificación hídrica,

investigaciones científicas,

proyectos de gestión territorial.

AquaGISVZLA moderniza esta información para garantizar su preservación y reutilización en nuevos trabajos académicos y técnicos.

📊 Estado del Proyecto
El sistema se encuentra en fase de consolidación, con los módulos ETL y las vistas espaciales completamente funcionales.
Las próximas etapas incluyen:

integración de litología,

análisis hidrogeoespacial avanzado,

generación de mapas interactivos,

publicación de dashboards web.

🎓 Proyección Académica
AquaGISVZLA servirá como base para futuros trabajos de investigación y como plataforma de análisis para el Máster en Sistemas de Información Geográfica (UNIGIS – Universitat de Girona).

🧩 Autor
Derinson Rojas
Ingeniero de Geólogo | SIG & ETL Developer
Proyecto AquaGISVZLA — Modernización hidrogeoespacial de Venezuela.