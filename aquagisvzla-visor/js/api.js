export async function obtenerPozos() {
    const response = await fetch('https://aquagisvzla-sigatlas-jo7l.onrender.com/pozos');
    if (!response.ok) {
        throw new Error('Error al obtener los pozos');
    }
    return await response.json();
}
