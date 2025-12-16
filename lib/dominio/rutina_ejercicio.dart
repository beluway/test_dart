class RutinaEjercicio {

  int? idRutina;
  int? idEjercicio;
  int repeticiones;

  //constructor
  RutinaEjercicio({required this.idRutina, required this.idEjercicio, required this.repeticiones});

  factory RutinaEjercicio.fromMap(Map<String, Object?> mapa){
    return RutinaEjercicio(
      idRutina: (mapa['id_rutina'] as int?) ?? 0,
      idEjercicio: (mapa['id_ejercicio'] as int?) ?? 0,
      repeticiones: (mapa['repeticiones'] as int?) ?? 0
      );
  } 

   Map<String, Object?> toMap() {
    return {
      'id_rutina': idRutina,
      'id_ejercicio': idEjercicio,
      'repeticiones': repeticiones,
    };
  }

}