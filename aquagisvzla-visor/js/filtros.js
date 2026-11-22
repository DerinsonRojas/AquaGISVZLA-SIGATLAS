export const OPCIONES_AUDITORIA = [
  "COINCIDE",
  "NO COINCIDE",
  "SIN ENTIDAD",
  "FUERA DE LIMITES"
];

/**
 * Filtra un GeoJSON FeatureCollection según el valor de auditoria_estado seleccionado.
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

/**
 * Conecta los controles del sidebar y dispara onChange(modo) cuando cambian.
 */
export function inicializarControlesSidebar(onChange, modoInicial = "UTILES") {
  const select = document.getElementById("select-auditoria");
  const btnReset = document.getElementById("btn-reset-filtros");
  const btnToggle = document.getElementById("btn-toggle-sidebar");
  const sidebar = document.getElementById("sidebar-filtros");
  inicializarInfoAuditoria();

  if (select) {
    select.value = modoInicial;
    select.addEventListener("change", (e) => {
      onChange(e.target.value);
    });
  }

  if (btnReset && select) {
    btnReset.addEventListener("click", () => {
      select.value = modoInicial;
      onChange(modoInicial);
    });
  }

  if (btnToggle && sidebar) {
    btnToggle.addEventListener("click", () => {
      sidebar.classList.toggle("collapsed");
    });
  }
}

export function actualizarContadorPozos(visibles, total) {
  const contador = document.getElementById("contador-pozos");
  if (!contador) return;
  contador.textContent = `Mostrando ${visibles.toLocaleString("es-VE")} de ${total.toLocaleString("es-VE")} pozos`;
}

function inicializarInfoAuditoria() {
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