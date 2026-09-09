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
       │      pozos_quimica       │           │     pozos_litologia_limpios │
       │──────────────────────────│           │──────────────────────────│
       │ id_pozo (FK)             │           │ id_pozo (FK)             │
       │ fecha_analisis           │           │ desde, hasta             │
       │ ph, ce, na, k, etc.      │           │ litologia                │
       └──────────────┬───────────┘           └──────────────┬───────────┘
                      │ 1:N                   │ 1:N
                      ▼                       ▼
       ┌──────────────────────────┐           ┌──────────────────────────┐
       │     pozos_nivel_limpios  │           │     pozos_fisicos        │
       │──────────────────────────│           │──────────────────────────│
       │ id_pozo (FK)             │           │ id_pozo (FK)             │
       │ fecha_medicion           │           │ prof_perforacion_m       │
       │ nivel_estatico_m         │           │ prof_entubado_m          │
       │ nivel_dinamico_m         │           │ diametro_superior_in     │
       │ gasto_l_s                │           │ diametro_inferior_in     │
       └──────────────────────────┘           └──────────────────────────┘

───────────────────────────────────────────────────────────────────────────────
A partir de v1.5, el modelo relacional queda completamente enlazado:

pozos_master (PK)
├── pozos_quimica (FK) → 1:N
├── pozos_litologia_limpios (FK) → 1:N
├── pozos_nivel_limpios (FK) → 1:N
└── pozos_fisicos (FK) → 1:1

Nueva vista para QGIS:
v_pozos_lacanoa_corregido_qgis → vista espacial optimizada con husos UTM
