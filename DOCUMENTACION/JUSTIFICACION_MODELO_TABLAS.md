
🟩 Justificación del modelo de tablas — AquaGISVZLA
El modelo relacional de AquaGISVZLA se diseñó para mantener la integridad de las tablas principales y permitir la depuración segura de datos legacy sin afectar el futuro flujo ETL.

1. pozos_master
Se eliminaron registros absurdos (“ZZ”, etc.).

No se creó una tabla nueva para preservar la estructura oficial del sistema.

Mantener esta tabla estable garantiza compatibilidad con funciones y triggers existentes.

La PK y la estructura deben permanecer intactas.

2. pozos_quimica
Contenía pozos huérfanos.

Se eliminaron directamente por ser pocos.

No se creó una tabla nueva debido a la complejidad de la entidad y sus reglas de negocio.

Mantener la tabla original evita romper el ETL que inyectará datos en el futuro.

3. pozos_litologia y pozos_nivel
Tenían menor complejidad estructural.

Se separaron huérfanos sin afectar la lógica del sistema.

Se crearon tablas _limpios y _huerfanos para mantener la original y disponer de datos depurados para análisis.

No requieren triggers ni funciones, por lo que crear tablas nuevas fue la opción más limpia.

4. Tabla de datos físicos de pozo pozos_fisicos

En la tabla pozos_master tenemos datos de propiedades física y de entubación que no identifican al pozo sino que responden a características físicas, por eso se ha creado esta tabla auxiliar. Para consultar solo este tipo de información sin ver a pozos_master entero.

5. Relación entre tablas
Las tablas derivadas (_limpios) contienen registros con FK válida hacia pozos_master.

Las tablas _huerfanos contienen registros sin correlación.

Todas las entidades se relacionan mediante id_pozo.

6. Tablas de auditorías 

Las tablas de auditorías fueron creadas para registrar cada eliminación o cambio en un registro de las respectivas tablas originales

7. Tablas catálogo

Las tablas de catálago vienen de la data legacy, se han creado para salvar esa información original del SIGATLAS en ACCES pero son informativas y por la forma en que se fue registrada la litología en pozos_litologia, no es posible usar dichos catálogos para hacer asociaciones.

8. spatial_ref_sys
La ha creado postGIS automaticamente al ejecutar:

CREATE EXTENSION postgis;

Es parte del núcleo de postGIS

spatial_ref_sys es la tabla interna de PostGIS que contiene los sistemas de referencia espacial (SRID).
Es utilizada por QGIS y por funciones como ST_SetSRID y ST_Transform.



