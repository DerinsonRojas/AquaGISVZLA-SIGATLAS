import { inicializarPanelAuditoria } from "./auditoria.js";

export function inicializarSidebar(onChangeFiltro, modoInicial = "UTILES") {
  const select = document.getElementById("select-auditoria");
  const btnReset = document.getElementById("btn-reset-filtros");
  const btnToggle = document.getElementById("btn-toggle-sidebar");
  const sidebar = document.getElementById("sidebar-filtros");

  inicializarPanelAuditoria();
  inicializarInfoVisor();

  if (select) {
    select.value = modoInicial;
    select.addEventListener("change", (e) => {
      onChangeFiltro(e.target.value);
    });
  }

  if (btnReset && select) {
    btnReset.addEventListener("click", () => {
      select.value = modoInicial;
      onChangeFiltro(modoInicial);
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

function inicializarInfoVisor() {
  const btnInfo = document.getElementById("btn-info-visor");
  const panelInfo = document.getElementById("panel-info-visor");
  const btnCerrar = document.getElementById("btn-cerrar-info-visor");

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