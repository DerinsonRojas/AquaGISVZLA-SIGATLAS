export const OPCIONES_AUDITORIA = [
  "COINCIDE",
  "NO COINCIDE",
  "SIN ENTIDAD",
  "FUERA DE LIMITES"
];

/**
 * Filtra un GeoJSON FeatureCollection según el modo de auditoría.
 * Por defecto ("UTILES") excluye "FUERA DE LIMITES".
 */
export function filtrarPorAuditoria(geojson, modo = "UTILES") {
  if (!geojson || !Array.isArray(geojson.features)) {
    return { type: "FeatureCollection", features: [] };
  }

  const features = geojson.features.filter((feature) => {
    const rawEstado = feature?.properties?.auditoria_estado;
    const estado = typeof rawEstado === "string" ? rawEstado.trim().toUpperCase() : "";

    if (modo === "TODOS") return true;
    if (modo === "UTILES") return estado !== "FUERA DE LIMITES";
    return estado === modo;
  });

  return {
    type: "FeatureCollection",
    features
  };
}

export function inicializarPanelAuditoria() {
  const btnInfo = document.getElementById("btn-info-auditoria");
  const panelInfo = document.getElementById("info-auditoria-panel");
  const btnCerrar = document.getElementById("btn-cerrar-info-auditoria");

  if (!btnInfo || !panelInfo) return;

  btnInfo.addEventListener("click", () => {
    const estaOculto = panelInfo.classList.toggle("oculto");
    btnInfo.setAttribute("aria-expanded", String(!estaOculto));
  });

  if (btnCerrar) {
    btnCerrar.addEventListener("click", () => {
      panelInfo.classList.add("oculto");
      btnInfo.setAttribute("aria-expanded", "false");
    });
  }
}