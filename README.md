Markdown
# 🌎 AquaGISVZLA — Plataforma Hidrogeoespacial de Pozos de Agua de Venezuela

**Sistema integral de ingeniería de datos, geoprocesamiento y visualización hidrogeoespacial**

**AquaGISVZLA** es una plataforma de código abierto para la depuración, normalización, migración, consulta y visualización web de registros históricos de pozos profundos de agua subterránea en Venezuela. El proyecto moderniza una base de datos *legacy* del antiguo Ministerio del Ambiente (hasta 2006), utilizada durante décadas en:

- Tesis de pregrado y postgrado
- Estudios hidrogeológicos
- Planificación hídrica
- Investigaciones científicas
- Proyectos de gestión territorial

AquaGISVZLA reconstruye y publica esta información mediante un pipeline ETL en Python, una base de datos espacial PostgreSQL + PostGIS en la nube, una API REST con FastAPI y un visor web interactivo con Leaflet, con proyección hacia análisis estratigráficos y dashboards hidrogeoespaciales avanzados.

---

## 🚀 Estado Actual del Sistema (Producción)

- **Base de Datos Espacial (Supabase):** PostgreSQL + PostGIS (>14.000 pozos), conectada mediante *Connection Pooler* (`sslmode=require`) y con gestión segura de credenciales mediante variables de entorno.
- **Backend API REST (Render):** Servicio en Python (**FastAPI** + `psycopg2`) desplegado en producción (`https://aquagisvzla-sigatlas-jo7l.onrender.com/pozos`), con ruta raíz (`/`) y documentación interactiva (`/docs`).
- **Visor Web Interactivo (GitHub Pages):** Aplicación estática con **Leaflet** publicada en GitHub Pages (`https://derinsonrojas.github.io/AquaGISVZLA-SIGATLAS/aquagisvzla-visor/index.html`), consumiendo el GeoJSON directamente desde el endpoint de producción en Render.
- **Flujo de Versionado:** Rama principal `main` estable en producción, desarrollo de nuevas funcionalidades en ramas `feature/...` y registro de versiones en `CHANGELOG.md` (hasta `v2.2`).

---

## 🧩 Características Técnicas Principales

### 1. Pipeline ETL Profesional (Python + Pandas)
- Limpieza, normalización y estandarización de datos *legacy*.
- Eliminación de duplicados y corrección de tipos de datos.
- Validación estricta de integridad referencial.
- Patrón de carga masiva: `STAGING → VALIDACIÓN → SWAP → VERIFICACIÓN`.

### 2. Modelo Relacional Modernizado
- Separación física de atributos (`pozos_master`, `pozos_quimica`, `pozos_litologia`, `pozos_nivel`, `datos_técnicos`).
- Claves primarias y foráneas activas (`PK–FK`).
- Tablas `_limpios` y `_huerfanos` para trazabilidad y auditoría.

### 3. Geoprocesamiento Avanzado (PostGIS)
- Interpretación del datum *legacy* La Canoa (`PSAD56` UTM) y transformación precisa a `WGS84` (`EPSG:4326`).
- Corrección de desplazamientos históricos y generación de geometrías compatibles con QGIS y visores web.
- Cálculo de altitud de cada pozo a partir del mosaico de elevación **NASADEM** de Venezuela.
- Vista espacial oficial `v_pozos_wgs84_dd_qgis` (optimizada en grados decimales para QGIS y aplicaciones web).

### 4. Automatización y Reglas de Negocio
- Flujo ETL modular por fases y refactorizado sin `TRUNCATE`.
- Validaciones automáticas en *staging* y *swap* atómico para cargas masivas.
- Funciones y *triggers* PL/pgSQL para reglas de negocio.

### 5. Visor Geoespacial y API REST
- Endpoint GeoJSON desacoplado en FastAPI (`/pozos`) servido desde Render.
- Cliente web en Leaflet (`api.js` + `index.html`) desplegado en GitHub Pages, listo para incorporar menús laterales y filtros dinámicos.

### 6. Documentación Técnica Profesional
- Arquitectura SIG y justificación del modelo de tablas y vistas espaciales.
- Estándares de nombres de tablas y vistas SIG.
- Manual de ETL, libro blanco (`AquaGISVZLA.md`) y registro de versiones (`CHANGELOG.md`).

---

## 🛠️ Stack Tecnológico

| Tecnología / Componente | Rol en el Proyecto |
| :--- | :--- |
| **Python 3.x + Pandas** | Pipeline ETL, limpieza, validación y transformación de datos |
| **PostgreSQL + PostGIS (Supabase)** | Base de datos relacional y espacial en la nube con *Connection Pooler* |
| **FastAPI + psycopg2 (Render)** | API REST desacoplada para servir datos espaciales en formato GeoJSON |
| **Leaflet + GitHub Pages** | Visor web geoespacial interactivo y alojamiento estático |
| **QGIS** | Validación espacial, auditoría geométrica y cartografía |
| **Git / GitHub** | Control de versiones, ramas de trabajo y etiquetas de release |

---

## 📁 Estructura del Repositorio

```text
SIGATLASV1/
│
├── aquagisvzla-visor/          # Visor web estático (Leaflet, HTML/CSS/JS, api.js)
├── backend/                    # API REST en FastAPI y conexión a PostgreSQL/PostGIS
├── BBDD_SIGATLAS/              # Base de datos legacy (Access)
├── DATOS_ORIGINALES/           # Archivos fuente sin procesar
├── DATOS_PROCESADOS/           # Resultados del ETL (CSV limpios)
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
│   ├── POZOS_NIVEL/
│   │   └── ETL_FASE_2_POZOS_NIVEL.py
│   └── POZOS_DATOS_TECNICOS/
│       └── ETL_FASE_2_POZOS_DATOS_TECNICOS.py
│
├── GEOESPACIAL/                # Scripts PostGIS, vistas y funciones espaciales
│
├── SQL_CONSULTAS/
│   ├── LITOLOGIA/
│   ├── MASTER/
│   ├── POSTGRES_TO_QGIS/
│   ├── QUIMICA/
│   ├── DATOS_TECNICOS/
│   └── NIVEL/
│
├── CHANGELOG.md
├── .gitignore
└── README.md
🔁 Flujo de Trabajo (ETL y Despliegue)
Actualizar funciones PL/pgSQL (si se incorporan nuevas reglas de negocio o validaciones).

Ejecutar el ETL modular bajo el patrón STAGING → VALIDACIÓN → SWAP → VERIFICACIÓN (sin TRUNCATE).

Verificar geometrías y ubicación en QGIS mediante las vistas de control y auditoría (incluida v_pozos_geometria_auditoria_ubicacion_qgis y la vista oficial v_pozos_wgs84_dd_qgis).

Validar integridad relacional (PK–FK, huérfanos, duplicados y geometrías).

Desarrollar y probar en ramas feature/... en local contra la API de Render, haciendo merge a main solo cuando esté validado.

Commit + Push + Tag al repositorio para actualizar la documentación, Render y GitHub Pages.

🧭 Origen de la Data Legacy
La base original proviene del antiguo Ministerio del Ambiente de Venezuela, responsable de la gestión hídrica y ambiental del país hasta 2006. El proyecto rescata más de 14.000–15.000 registros históricos de pozos profundos (según depuración y trazabilidad de tablas _limpios y _huerfanos) para garantizar su preservación, consulta abierta y reutilización en estudios técnicos y científicos.

📊 Próximas Etapas
Implementación de menú lateral y filtros dinámicos en el visor web (aquagisvzla-visor).

Ampliación de consultas espaciales y dashboards hidrogeológicos interactivos.

🎓 Proyección Académica
AquaGISVZLA sirve como base técnica y de datos para trabajos de investigación, tesis de grado, proyectos hidrogeológicos y análisis SIG avanzados, en el marco del Máster en Teledetección, Tecnologías de la Información Geográfica y Ciencia de Datos Espaciales (UNIGIS – Universitat de Girona).

👤 Autor
Derinson Rojas

Ingeniero Geólogo | SIG & ETL Developer

Proyecto AquaGISVZLA — Modernización hidrogeoespacial de Venezuela.

Nota sobre la nomenclatura del repositorio: El directorio principal mantiene la denominación SIGATLASV1 por compatibilidad técnica y preservación de rutas en scripts ETL, consultas SQL y configuraciones de QGIS, aunque el nombre oficial del sistema es AquaGISVZLA.