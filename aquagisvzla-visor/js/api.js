export async function obtenerPozos() {
    const response = await fetch('https://aquagisvzla-sigatlas.onrender.com/pozos');
    if (!response.ok) {
        throw new Error('Error al obtener los pozos');
    }
    return await response.json();
}
