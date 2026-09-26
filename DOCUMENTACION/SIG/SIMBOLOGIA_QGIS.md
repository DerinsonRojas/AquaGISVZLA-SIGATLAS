### Interpretación de la simbología de auditoría espacial

La capa `v_pozos_wgs84_dd_qgis` utiliza una simbología tipo semáforo para representar el estado de coincidencia territorial de cada pozo.  
Los colores son **indicativos**, no restrictivos: ningún color excluye el uso del pozo en análisis posteriores.  
La selección de pozos para análisis hidrogeológicos o territoriales debe realizarse aplicando criterio técnico y conocimiento del área.

| Color | Categoría | Significado | Confiabilidad estimada |
|--------|------------|-------------|-------------------------|
| 🟢 Verde | COINCIDE | Pozo con ubicación verificada y coherente con su entidad administrativa. | 100% fiable |
| 🟡 Amarillo | SIN ENTIDAD | Pozo en zona limítrofe o reclamada entre estados. Generalmente correcto, salvo casos aislados. | ~99% fiable |
| 🔴 Rojo | NO COINCIDE | Pozo con discrepancia entre ubicación física y nombre de estado. Puede ser válido si está cerca de una divisoria natural (río, frontera). | Variable |
| 🔵 Azul | FUERA DE LÍMITES | Pozo fuera del polígono oficial de Venezuela. Puede existir un pozo real próximo al límite vectorial. | Bajo, revisar manualmente |
| ⚫ Gris | SIN VALOR / NULL | Pozo sin auditoría o sin coincidencia evaluada. No existen casos activos, pero se mantiene para compatibilidad futura. | N/A |

**Nota:**  
La simbología orienta, pero no determina la validez de los datos.  
El color gris se reserva para casos `NULL` o sin evaluación, actualmente inexistentes.
