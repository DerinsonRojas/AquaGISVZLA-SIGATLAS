import { obtenerPozos } from './api.js';

// Crear mapa centrado en Venezuela
const map = L.map('map').setView([7.5, -66.5], 6);

// Capa base OpenStreetMap
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 18,
    attribution: '© OpenStreetMap'
}).addTo(map);

// Función para cargar pozos desde el backend
async function cargarPozos() {
    try {
        const geojson = await obtenerPozos();

        L.geoJSON(geojson, {
            pointToLayer: function (feature, latlng) {
                return L.circleMarker(latlng, {
                    radius: 5,
                    color: 'blue',
                    fillColor: 'cyan',
                    fillOpacity: 0.7
                });
            },

            onEachFeature: function (feature, layer) {
                const p = feature.properties;

                // Convertir booleanos a texto legible
                const quimica = p.tiene_quimica ? "✅ Sí" : "❌ No";
                const litologia = p.tiene_litologia ? "✅ Sí" : "❌ No";
                const niveles = p.tiene_niveles ? "✅ Sí" : "❌ No";
                const datos_tecnicos = p.tiene_datos_tecnicos ? "✅ Sí" : "❌ No";

                // Crear popup con formato claro y profesional
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

    } catch (error) {
        console.error('Error cargando pozos:', error);
    }
}

// Ejecutar carga de pozos
cargarPozos();

