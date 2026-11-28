import { inicializarMapa, cargarPozosEnMapa, establecerModoFiltro } from "./map.js";
import { inicializarSidebar } from "./sidebar.js";

async function cargarComponente(ruta, selectorDestino, modo = "append") {
  const respuesta = await fetch(ruta);
  if (!respuesta.ok) {
    throw new Error(`No se pudo cargar el componente ${ruta} (${respuesta.status})`);
  }
  const html = await respuesta.text();
  const destino = document.querySelector(selectorDestino);
  if (!destino) {
    throw new Error(`No existe el contenedor ${selectorDestino}`);
  }

  if (modo === "replace") {
    destino.innerHTML = html;
  } else {
    destino.insertAdjacentHTML("beforeend", html);
  }
}

async function iniciarAplicacion() {
  try {
    // 1. Montar componentes de interfaz en el DOM
    await cargarComponente("./src/components/header.html", "body", "append");
    await cargarComponente("./src/components/visor-info.html", "body", "append");
    await cargarComponente("./src/components/sidebar.html", "body", "append");
    await cargarComponente("./src/components/auditoria-panel.html", "#contenedor-auditoria-panel", "replace");

    // 2. Inicializar mapa y controles ya presentes en el DOM
    inicializarMapa();
    inicializarSidebar((nuevoModo) => {
      establecerModoFiltro(nuevoModo);
    }, "UTILES");

    // 3. Cargar datos desde la API
    await cargarPozosEnMapa();
  } catch (error) {
    console.error("Error iniciando AquaGIS Venezuela:", error);
  }
}

iniciarAplicacion();