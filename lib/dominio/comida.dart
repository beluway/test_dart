class Comida {
  int idIndicacion;
  String hora;
  String? descripcion;

  Comida({
    required this.idIndicacion,
    required this.hora,
    this.descripcion,
  });

  factory Comida.fromMap(Map<String, Object?> mapa) {
    return Comida(
      idIndicacion: mapa['id_indicacion'] as int,
      hora: mapa['hora'] as String,
      descripcion: mapa['descripcion'] as String?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id_indicacion': idIndicacion,
      'hora': hora,
      'descripcion': descripcion,
    };
  }
}