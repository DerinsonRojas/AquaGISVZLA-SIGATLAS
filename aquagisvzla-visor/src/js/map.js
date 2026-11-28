import { obtenerPozos } from "../../js/api.js";
import { filtrarPorAuditoria } from "./auditoria.js";
import { actualizarContadorPozos } from "./sidebar.js";

let map = null;
let geojsonOriginal = null;
let capaPozos = null;
let modoFiltroActual = "UTILES";

export function inicializarMapa() {
  map = L.map("map").setView([7.5, -66.5], 6);

  L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
    maxZoom: 18,
    attribution: "© OpenStreetMap"
  }).addTo(map);
}

function crearCapaPozos(geojsonFiltrado) {
  if (!map) return;

  if (capaPozos) {
    map.removeLayer(capaPozos);
  }

  capaPozos = L.geoJSON(geojsonFiltrado, {
    pointToLayer: function (feature, latlng) {
      const estado = feature.properties.auditoria_estado;
      let color = "gray";

      switch (estado) {
        case "COINCIDE":
          color = "green";
          break;
        case "FUERA DE LIMITES":
          color = "blue";
          break;
        case "NO COINCIDE":
          color = "red";
          break;
        case "SIN ENTIDAD":
          color = "#ff9900";
          break;
      }

      return L.circleMarker(latlng, {
        radius: 5,
        color: color,
        fillColor: color,
        fillOpacity: 0.7
      });
    },

    onEachFeature: function (feature, layer) {
      const p = feature.properties;

      const quimica = p.tiene_quimica ? "✅ Sí" : "❌ No";
      const litologia = p.tiene_litologia ? "✅ Sí" : "❌ No";
      const niveles = p.tiene_niveles ? "✅ Sí" : "❌ No";
      const datos_tecnicos = p.tiene_datos_tecnicos ? "✅ Sí" : "❌ No";

      const popup = `
        <div style="font-family: Arial; font-size: 13px;">
          <b>ID Pozo:</b> ${p.id_pozo}<br>
          <b>Estado:</b> ${p.estado}<br>
          <b>Auditoría de estado:</b> ${p.auditoria_estado || "Sin dato"}<br>
          <b>Lat:</b> ${p.lat_dd}<br>
          <b>Lon:</b> ${p.lon_dd}<br>
          <hr style="margin: 4px 0;">
          <b>Indicadores:</b><br>
          Química: ${quimica}<br>
          Litología: ${litologia}<br>
          Niveles: ${niveles}<br>
          Datos técnicos del pozo: ${datos_tecnicos}
        </div>
      `;

      layer.bindPopup(popup);
    }
  }).addTo(map);

  const total = geojsonOriginal?.features?.length ?? 0;
  const visibles = geojsonFiltrado?.features?.length ?? 0;
  actualizarContadorPozos(visibles, total);
}

export function establecerModoFiltro(nuevoModo) {
  modoFiltroActual = nuevoModo;
  if (!geojsonOriginal) return;
  const filtrado = filtrarPorAuditoria(geojsonOriginal, modoFiltroActual);
  crearCapaPozos(filtrado);
}

export async function cargarPozosEnMapa() {
  try {
    geojsonOriginal = await obtenerPozos();
    establecerModoFiltro(modoFiltroActual);
  } catch (error) {
    console.error("Error cargando pozos:", error);
  }
}