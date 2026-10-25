export async function obtenerPozos() {
    const response = await fetch('http://127.0.0.1:8000/pozos');
    if (!response.ok) {
        throw new Error('Error al obtener los pozos');
    }
    return await response.json();
}
