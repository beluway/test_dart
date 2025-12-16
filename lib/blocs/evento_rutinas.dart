import 'package:flutter/foundation.dart';
import 'package:test_dart/dominio/dominios.dart'; // Necesitas EjercicioDetallado

// --- CLASE BASE DE EVENTOS ---
@immutable
abstract class EventoRutinas {
  const EventoRutinas();
}


/* class AgregarEjercicioARutina extends EventoRutinas {
 final DateTime fecha;
 final RutinaEjercicio nuevoRegistro; // Contiene idEjercicio e repeticiones
 
 const AgregarEjercicioARutina({
 required this.fecha,
 required this.nuevoRegistro,
 });
} */

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
  final String nombreEjercicio; // El nombre de texto libre
  final int repeticiones;

  const AgregarEjercicioPorNombre({
    required this.fecha,
    required this.nombreEjercicio,
    required this.repeticiones,
  });

  @override
  List<Object?> get props => [fecha, nombreEjercicio, repeticiones];
}

// Evento disparado para modificar un ejercicio existente.
class EditarEjercicioDeRutina extends EventoRutinas {
  final Ejercicio ejercicioActualizado;

  const EditarEjercicioDeRutina(this.ejercicioActualizado);
  
  @override
  String toString() => 'EditarEjercicioDeRutina { ejercicio: ${ejercicioActualizado.nombre} }';
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
  
  @override
  String toString() => 'EliminarEjercicioDeRutina { idRutinaEjercicio: $idRutina, fecha: $fechaActual }';
}

class ListarRutinaEjercicio extends EventoRutinas{}