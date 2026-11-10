# 📜 CHANGELOG — AquaGISVZLA

Este documento registra los cambios más importantes del proyecto AquaGISVZLA por versión, siguiendo buenas prácticas de control de versiones y documentación técnica.


## v2.1 - 2026-11-10

### Added
- Ruta principal (`/`) en FastAPI con respuesta JSON informativa sobre el estado del sistema y acceso a la documentación interactiva (`/docs`).
- Confirmación y verificación de compatibilidad de despliegue del visor frontend en **GitHub Pages**.

### Improved
- Enrutamiento REST refactorizado: la consulta de pozos y generación GeoJSON se mantiene exclusivamente en la ruta `/pozos`.

### Fixed
- Solucionado el error `404 Not Found` en la ruta raíz del backend local (`http://127.0.0.1:8000/`).

---
---

## 🟩 v2.0 — Visor Web Local + Arquitectura Integrada (19/10/2026)

### Added
- Backend FastAPI con endpoint `/pozos` sirviendo GeoJSON desde PostgreSQL + PostGIS.
- Visor web local basado en Leaflet + Vite.
- Simbología dinámica por `auditoria_estado` (COINCIDE, FUERA DE LIMITES, NO COINCIDE, SIN ENTIDAD).
- Popups con indicadores booleanos (química, litología, niveles, datos técnicos).
- Estructura modular del visor (`css/`, `js/`, `public/`, `src/`).
- Documentación profesional: README, ROADMAP, actualización de VERSIONES.md.
- Reorganización completa del repositorio con separación clara entre backend, visor, ETL y documentación.

### Improved
- Refactor visual del popup.
- Ajuste del color “SIN ENTIDAD” a un tono naranja más agradable.
- Limpieza del repositorio y actualización de `.gitignore`.
- Estabilidad del backend al iniciar con `uvicorn`.

### Fixed
- Doble instancia de FastAPI que impedía el funcionamiento correcto de CORS.
- Corrección del tipo de dato `id_pozo` en el modelo Pydantic.
- Errores menores en la estructura del visor y rutas internas.

---

## 🟦 v1.8 — Preparación para el visor web + Optimización técnica (13/10/2026)

### Added
- Implementación del dump binario (`pg_dump -Fc`) como método oficial de respaldo.
- Documentación del proceso de restauración en `MANUAL_RESTAURACION_BD.md`.

### Improved
- Eliminación del TRUNCATE del flujo ETL.
- Limpieza completa del repositorio.
- Optimización del entorno técnico para despliegues futuros.

### Fixed
- Restauración exitosa en entorno aislado para validar reproducibilidad.

---

## 🟩 v1.7 — Refactorización estructural del sistema de pozos (26/09/2026)

### Added
- Normalización de `pozos_master` y separación de atributos físicos.
- Automatización del ETL de litología con nuevas reglas y triggers.
- Vista `v_pozos_relaciones` para auditoría relacional.

### Improved
- Eliminación de dependencias CASCADE.
- Consolidación de claves foráneas hacia `pozos_master`.

### Fixed
- Depuración masiva de litologías duplicadas o inválidas.

---

*(Las versiones anteriores continúan en el documento VERSIONES.md)*

