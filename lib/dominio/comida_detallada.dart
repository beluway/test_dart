// Clase que representa el resultado final para la UI

class ComidaDetallada {
  final String nombre;
  final String descripcion;
  final String fecha;
  final String hora;

  ComidaDetallada({
    required this.nombre,
    required this.descripcion,
    required this.fecha,
    required this.hora,
  });

    factory ComidaDetallada.fromMap(Map<String, Object?> mapa){
    return ComidaDetallada(
      nombre: mapa['nombre'] as String,
      descripcion: mapa['descripcion'] as String,
      fecha: mapa['fecha'] as String,
      hora: mapa['hora'] as String);
  }

    Map<String, Object?> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'fecha': fecha,
      'hora': hora,
    };
  }
}