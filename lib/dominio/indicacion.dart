class Indicacion {
  final int id;
  final DateTime fecha;

  Indicacion({
    required this.id,
    required this.fecha,
  });

  factory Indicacion.fromMap(Map<String, Object?> mapa) {
    return Indicacion(
      id: mapa['id'] as int,
      fecha: DateTime.parse(mapa['fecha'] as String),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'fecha': fecha.toIso8601String(),
    };
  }
}