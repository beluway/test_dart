class Rutina {
  int id;
  int idIndicacion;

  Rutina({
    required this.id,required this.idIndicacion});

  factory Rutina.fromMap(Map<String, Object?> mapa) {
    return Rutina(
      id: mapa['id'] as int,
      idIndicacion: mapa['id_indicacion'] as int,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id' : id,
      'id_indicacion': idIndicacion,
    };
  }
}