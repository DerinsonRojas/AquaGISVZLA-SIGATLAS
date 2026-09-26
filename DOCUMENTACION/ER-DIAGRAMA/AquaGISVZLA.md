                             ┌───────────────────────────┐
                             │       pozos_master        │
                             │───────────────────────────│
                             │ id_pozo (PK)              │
                             │ estado                    │
                             │ municipio                 │
                             │ parroquia                 │
                             │ latitud, longitud         │
                             │ norte_m, este_m           │
                             │ propietario               │
                             │ tiene_geometria           │
                             └──────────────┬────────────┘
                                            │ 1
                                            │
                                            ▼
       ┌──────────────────────────┐           ┌──────────────────────────┐
       │      pozos_quimica       │           │ pozos_litologia          │
       │──────────────────────────│           │──────────────────────────│
       │ id_pozo (FK)             │           │ id_pozo (FK)             │
       │ fecha_analisis           │           │ desde, hasta             │
       │ ph, ce, na, k, etc.      │           │ litologia                │
       │ FK: fk_pozos_quimica_master │        │ FK: fk_pozos_litologia_master │
       └──────────────┬───────────┘           └──────────────┬───────────┘
                      │ 1:N                   │ 1:N
                      ▼                       ▼
       ┌──────────────────────────┐           ┌──────────────────────────┐
       │     pozos_nivel          │           │ pozos_datos_tecnicos     │
       │──────────────────────────│           │──────────────────────────│
       │ id_pozo (FK)             │           │ id_pozo (FK)             │
       │ fecha_medicion           │           │ prof_perforacion_m       │
       │ nivel_estatico_m         │           │ prof_entubado_m          │
       │ nivel_dinamico_m         │           │ diametro_superior_in     │
       │ gasto_l_s                │           │ diametro_inferior_in     │
       │ FK: fk_pozos_nivel_master│           │ FK: fk_pozos_datos_tecnicos_master │
       └──────────────┬───────────┘           └──────────────┬───────────┘
                      │ 1:1                   │ 1:1
                      ▼                       ▼
       ┌──────────────────────────┐
       │ pozos_grados_decimales_wgs84 │
       │──────────────────────────│
       │ id_pozo (FK)             │
       │ lat_dd, lon_dd           │
       │ geom_wgs84               │
       │ FK: fk_pozos_grados_decimales_master │
       └──────────────────────────┘

Actualización correspondiente a v1.7

pozos_master (PK)
│
├── pozos_quimica (1:N)
├── pozos_litologia (1:N)
├── pozos_nivel (1:N)
├── pozos_datos_tecnicos (1:1)
└── pozos_grados_decimales_wgs84 (1:1)

Vistas:
- v_pozos_relaciones (auditoría relacional)
- v_pozos_wgs84_auditoria_ubicacion_qgis (auditoría espacial)
- v_pozos_grados_decimales_wgs84 (vista espacial optimizada)

Integridad:
- 0 huérfanos
- Sin CASCADE
- Triggers ETL activos
- Compatible con QGIS y visor web (v2.0)

