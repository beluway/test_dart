import 'package:flutter/foundation.dart';

// --- CLASE BASE DE EVENTOS ---
@immutable
abstract class EventoRutinas {
  const EventoRutinas();
}

class AgregarEjercicioARutina extends EventoRutinas {
 final DateTime fecha;
 final int idEjercicio; // El ID del Ejercicio a añadir
 final int repeticiones; // Las repeticiones del ejercicio

 const AgregarEjercicioARutina({
  required this.fecha,
  required this.idEjercicio,
  required this.repeticiones,
 });
}

class AgregarEjercicioPorNombre extends EventoRutinas {
  final DateTime fecha;
  final String nombreEjercicio;
  final int repeticiones;
  // 🚨 NUEVO CAMPO NECESARIO
  final String descripcion; 

  const AgregarEjercicioPorNombre({
    required this.fecha,
    required this.nombreEjercicio,
    required this.repeticiones,
    this.descripcion = '', // Valor por defecto opcional en el constructor
  });

  List<Object?> get props => [fecha, nombreEjercicio, repeticiones, descripcion];
}

// Evento disparado para modificar un ejercicio existente.
class ModificarEjercicioRutina extends EventoRutinas {
  final int idRutinaOriginal; // ID de la rutina donde está el registro
  final int idEjercicioOriginal; // ID del EJERCICIO que se va a reemplazar/actualizar
  
  final String nuevoNombreEjercicio; // Puede ser el mismo o uno nuevo
  final int nuevaRepeticiones;
  final DateTime fechaRutina; // Para la recarga de la vista
  final String nuevaDescripcion; // Nuevo campo

  const ModificarEjercicioRutina({
    required this.idRutinaOriginal,
    required this.idEjercicioOriginal,
    required this.nuevoNombreEjercicio,
    required this.nuevaRepeticiones,
    required this.fechaRutina,
    required this.nuevaDescripcion,
  });

  List<Object?> get props => [
    idRutinaOriginal, 
    idEjercicioOriginal, 
    nuevoNombreEjercicio, 
    nuevaRepeticiones,
    fechaRutina,
    nuevaDescripcion
  ];
}

// Evento disparado para eliminar un ejercicio de la rutina.
class EliminarEjercicioDeRutina extends EventoRutinas {
  final int idRutina; 
  final int idEjercicio;
  final String nombreEjercicio;
  final DateTime fechaActual; 

  const EliminarEjercicioDeRutina({
    required this.idRutina, 
    required this.idEjercicio, 
    required this.nombreEjercicio, 
    required this.fechaActual,
  });
  
  List<Object?> get props => [idRutina, idEjercicio, nombreEjercicio, fechaActual];
}

class EliminarRutinaCompleta extends EventoRutinas {
    final int idRutina;
    final DateTime fecha;

    const EliminarRutinaCompleta({
        required this.idRutina,
        required this.fecha,
    });

    List<Object?> get props => [idRutina, fecha];
}

class ListarRutinaEjercicio extends EventoRutinas{}