🟩 v1.7 — Refactorización de pozos_master + Automatización de pozos_litologia + Consolidación relacional (26/09/2026)
🎯 Objetivo general
En esta versión se consolidan tres mejoras críticas del sistema:

Normalización estructural de pozos_master (1N)

Automatización completa de la limpieza y validación de pozos_litologia

Consolidación de relaciones PK–FK y creación de vista de auditoría

Estas tareas garantizan la expansión del modelo hidrogeológico y la integridad del sistema sin dependencias peligrosas como CASCADE.

🟦 1. Refactorización de pozos_master (Primera Forma Normal)
Se retiran de pozos_master todas las columnas que pertenecen a la entidad física del pozo, cumpliendo con la normalización en 1N.

Cambios realizados
Separación de atributos físicos hacia la nueva tabla pozos_fisicos.

Preparación del ETL dedicado para pozos_fisicos.

Reorganización del proceso de carga desde el CSV original.

Ajuste de dependencias internas para que pozos_master quede como tabla de identificación y metadatos.

Este cambio es imprescindible para continuar con la normalización del modelo.

🟩 2. Automatización completa de la tabla pozos_litologia
Se implementa un sistema de limpieza inteligente que elimina la necesidad de correcciones manuales futuras.

🔧 Reglas de negocio implementadas (trigger BEFORE INSERT/UPDATE)
Validación de existencia del pozo (evita registros huérfanos).

Eliminación automática de litologías nulas.

Normalización de litologías con espacios y sufijo “X”.

Prevención de duplicados con fecha distinta.

Unificación automática de fechas por mayoría (fallback: 1994‑01‑18).

🧹 Depuración masiva ejecutada
Eliminación de huérfanos.

Eliminación de duplicados.

Normalización de litologías.

Unificación de fechas.

Limpieza de sufijos y espacios.

Corrección de 82 registros en segundos.

🔒 3. Eliminación de CASCADE en los ETL
Se retira completamente el uso de:

ON DELETE CASCADE

ON UPDATE CASCADE

Esto evita pérdidas masivas de datos litológicos y garantiza que la integridad se controle exclusivamente mediante reglas de negocio y triggers.

🟦 4. Creación y consolidación de claves foráneas estables
Se crean y verifican las relaciones PK–FK hacia pozos_master:

Tabla hija	Llave foránea	Relación
pozos_litologia	fk_pozos_litologia_master	id_pozo → pozos_master.id_pozo
pozos_nivel	fk_pozos_nivel_master	id_pozo → pozos_master.id_pozo
pozos_quimica	fk_pozos_quimica_master	id_pozo → pozos_master.id_pozo
pozos_datos_tecnicos	fk_pozos_datos_tecnicos_master	id_pozo → pozos_master.id_pozo


Todas sin cascada, protegidas por triggers y totalmente compatibles con el estado actual del sistema.

🟩 5. Creación de vista de auditoría relacional
Se crea la vista v_pozos_relaciones para consultar las dependencias activas entre pozos_master y sus tablas satélite:

sql
CREATE OR REPLACE VIEW v_pozos_relaciones AS
SELECT
    tc.table_name AS tabla_hija,
    kcu.column_name AS columna_hija,
    ccu.table_name AS tabla_padre,
    ccu.column_name AS columna_padre,
    tc.constraint_name AS fk_nombre
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu
    ON tc.constraint_name = ccu.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND ccu.table_name = 'pozos_master';
Permite auditar fácilmente la integridad referencial del sistema.

⭐ Resultado final de la versión v1.7
pozos_master normalizado y estable.

pozos_litologia automatizada y blindada.

Integridad referencial completa entre todas las tablas satélite.

Eliminación de dependencias peligrosas (CASCADE).

Vista de auditoría relacional creada.

Sistema coherente, profesional y preparado para expansión.