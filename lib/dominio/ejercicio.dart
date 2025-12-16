class Ejercicio {
  int? id;
  String nombre;
  String? descripcion;

  Ejercicio({
    this.id,
    required this.nombre,
    this.descripcion,
  });

  factory Ejercicio.fromMap(Map<String, Object?> mapa) {
    return Ejercicio(
      id: mapa['id'] as int?,
      nombre: mapa['nombre'] as String,
      descripcion: mapa['descripcion'] as String?
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
    };
  }
}
