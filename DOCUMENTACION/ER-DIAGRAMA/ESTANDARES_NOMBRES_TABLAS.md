Nombramiento de tablas — AquaGISVZLA
1. Estructura general
Código
<grupo>_<entidad>_<detalle>
1.1. <grupo>
Define el tipo de tabla o su función dentro del modelo:

pozos → entidades principales y derivadas

catalogo → tablas maestras de referencia

auditoria → control de calidad y trazabilidad

etl → (si en el futuro creas tablas temporales de carga)

geo → (si creas tablas espaciales auxiliares)

1.2. <entidad>
Describe el tema o dominio:

litologia, nivel, quimica, fisicos, acuiferos, rocas, etc.

1.3. <detalle>
Indica el estado o propósito:

master → tabla principal

limpios → registros depurados

huerfanos → registros sin relación

validos → registros validados

temporal → tabla auxiliar

legacy → datos originales sin procesar

2. Ejemplos correctos 
Tipo	Ejemplo	Descripción
Tabla principal	pozos_master	Tabla base con identificación y ubicación.
Tabla derivada	pozos_litologia_limpios	Litología depurada y validada.
Tabla auxiliar	pozos_nivel_huerfanos	Registros sin relación con master.
Tabla de referencia	catalogo_rocas	Catálogo de tipos de roca.
Tabla de auditoría	auditoria_quimica	Registro de validaciones químicas.

3. Reglas obligatorias
✔ Usar snake_case (minúsculas y guiones bajos).

✔ Prefijo obligatorio según grupo (pozos_, catalogo_, auditoria_).

✔ Evitar nombres genéricos como datos, final, temp.

✔ Indicar el estado del dato (limpios, huerfanos, master, etc.).

✔ Mantener coherencia semántica entre tablas y vistas.

✔ No incluir el sistema de coordenadas en el nombre de la tabla (eso se reserva para vistas SIG).