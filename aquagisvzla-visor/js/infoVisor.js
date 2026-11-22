const DESCRIPCION_PROYECTO =
    "Visor geoespacial basado en el inventario SIGATLAS de pozos profundos en Venezuela. " +
    "Permite explorar su distribución territorial, filtrar según el contraste espacial de " +
    "auditoría con los límites estatales del IGVSB y consultar información técnica asociada.";

export function initInfoVisor() {
    const btnAbrir = document.getElementById("btn-info-visor");
    const btnCerrar = document.getElementById("btn-cerrar-info-visor");
    const panel = document.getElementById("panel-info-visor");
    const textoEl = document.getElementById("texto-info-visor");

    if (!btnAbrir || !panel) return;

    if (textoEl) {
        textoEl.textContent = DESCRIPCION_PROYECTO;
    }

    const setEstado = (abierto) => {
        panel.classList.toggle("oculto", !abierto);
        btnAbrir.setAttribute("aria-expanded", String(abierto));
    };

    btnAbrir.addEventListener("click", (e) => {
        e.stopPropagation();
        const estaAbierto = !panel.classList.contains("oculto");
        setEstado(!estaAbierto);
    });

    btnCerrar?.addEventListener("click", () => setEstado(false));

    document.addEventListener("click", (e) => {
        if (!panel.classList.contains("oculto") && !panel.contains(e.target) && e.target !== btnAbrir) {
            setEstado(false);
        }
    });

    document.addEventListener("keydown", (e) => {
        if (e.key === "Escape" && !panel.classList.contains("oculto")) {
            setEstado(false);
        }
    });
}