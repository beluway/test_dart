import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_dart/blocs/estados_rutinas.dart';
import 'package:test_dart/blocs/evento_rutinas.dart';
import 'package:test_dart/daos/daos.dart';

// Definición de Clases Auxiliares (mover a 'evento_rutinas.dart' o similar)
class CargarRutinaPorFecha extends EventoRutinas {
  final DateTime fecha;
  const CargarRutinaPorFecha({required this.fecha});

  List<Object?> get props => [fecha];
}

class BlocRutinas extends Bloc<EventoRutinas, EstadoRutinas> {
  // Uso de final para las dependencias para garantizar inmutabilidad
  final DaoRutinaEjercicio _daoRutinaEjercicio = DaoRutinaEjercicio();
  final DaoEjercicios _daoEjercicio = DaoEjercicios();
  final DaoRutinas _daoRutinas = DaoRutinas();

  BlocRutinas() : super(const CargandoRutinas()) {
    // Registro de manejadores de eventos
    on<CargarRutinaPorFecha>(_onCargarRutinaPorFecha);
    on<AgregarEjercicioARutina>(_onAgregarEjercicioARutina);
    on<AgregarEjercicioPorNombre>(_onAgregarEjercicioPorNombre);
    on<ModificarEjercicioRutina>(_onModificarEjercicioRutina);
    on<EliminarEjercicioDeRutina>(_onEliminarEjercicioDeRutina);
    on<EliminarRutinaCompleta>(_onEliminarRutinaCompleta);
  }

  // =========================================================================
  // MANEJADOR DE EVENTO: Cargar Rutina (Lectura)
  // =========================================================================

  Future<void> _onCargarRutinaPorFecha(
    CargarRutinaPorFecha evento,
    Emitter<EstadoRutinas> emit,
  ) async {
    // Si ya estamos en un estado de carga, no emitimos 'CargandoRutinas'
    // para evitar un parpadeo, pero lo emitimos si es necesario.
    if (state is! CargandoRutinas) {
      emit(const CargandoRutinas());
    }

    try {
      final List<Map<String, Object?>> rutina =
          await _daoRutinaEjercicio.obtenerRutinaCompletaPorFecha(evento.fecha);

      if (rutina.isNotEmpty) {
        emit(ExitoRutinas(rutina, 'Rutina cargada.'));
      } else {
        emit(const ExitoRutinas([], 'No hay rutina programada para este día.'));
      }
    } catch (e) {
      // Manejo genérico de errores durante la lectura
      emit(ErrorRutinas([], 'Error al cargar la rutina: ${e.toString()}'));
    }
  }

  // =========================================================================
  // MANEJADOR DE EVENTO: Agregar Ejercicio (Añadir por ID existente)
  // Se usa para ejercicios predefinidos (manteniendo la compatibilidad)
  // =========================================================================

  Future<void> _onAgregarEjercicioARutina(
    AgregarEjercicioARutina evento,
    Emitter<EstadoRutinas> emit,
  ) async {
    // Emitimos cargando para visualización y luego recargaremos
    emit(const CargandoRutinas());
    try {
      await _daoRutinaEjercicio.anadirEjercicioARutinaConFecha(
        fecha: evento.fecha,
        idEjercicio: evento.idEjercicio,
        repeticiones: evento.repeticiones,
      );

      // 1. Emitir un estado de éxito (opcional, pero útil para SnackBar de confirmación)
      emit(const OperacionExitosa('Ejercicio añadido a la rutina con éxito.'));

      // 2. Recargar la rutina para actualizar la UI
      add(CargarRutinaPorFecha(fecha: evento.fecha));
    } catch (e) {
      final String errorMsg = 'Fallo al añadir ejercicio por ID: ${e.toString()}';
      emit(ErrorRutinas([], errorMsg));
      // Intentar recargar el estado anterior (puede ser el último ExitoRutinas)
      add(CargarRutinaPorFecha(fecha: evento.fecha));
    }
  }

  // =========================================================================
  // MANEJADOR DE EVENTO: Agregar Ejercicio por Nombre (Creación Dinámica)
  // =========================================================================

  Future<void> _onAgregarEjercicioPorNombre(
    AgregarEjercicioPorNombre evento,
    Emitter<EstadoRutinas> emit,
  ) async {
    // 1. Emisión de carga (soluciona la "carga infinita")
    emit(const CargandoRutinas());

    try {
      // --- LÓGICA DE BÚSQUEDA/CREACIÓN DE EJERCICIO ---

      // Intenta obtener el ID. Si es null, lo crea (usando ??=)
      int? idEjercicio =
          await _daoEjercicio.obtenerIdPorNombre(evento.nombreEjercicio);

      // Si el ejercicio no existe, lo crea.
      // 🚨 Nota: Debes actualizar tu Evento 'AgregarEjercicioPorNombre' para incluir la descripción,
      // y tu DAO para aceptar la descripción.
      idEjercicio ??= await _daoEjercicio.crearEjercicio(
      evento.nombreEjercicio,
      // Se envía la descripción. Si el evento no la tiene o es "", el DAO le asignará el valor por defecto.
      descripcion: evento.descripcion, 
    );

      if (idEjercicio <= 0) {
        throw Exception('El ID del ejercicio es nulo o inválido (ID: $idEjercicio).');
      }

      // --- LÓGICA DE ADICIÓN A LA RUTINA ---
      await _daoRutinaEjercicio.anadirEjercicioARutinaConFecha(
        fecha: evento.fecha,
        idEjercicio: idEjercicio,
        repeticiones: evento.repeticiones,
      );

      // 4. Recargar la rutina para actualizar la UI (Flujo de éxito)
      add(CargarRutinaPorFecha(fecha: evento.fecha));
    } catch (e) {
      final String errorMsg = 'Error crítico al crear/añadir ejercicio: ${e.toString()}';
      
      // 5. Si hay error, EMITIMOS el estado de error y luego intentamos recargar
      emit(ErrorRutinas([], errorMsg));
      // Intentamos recargar el estado anterior para quitar el loading
      add(CargarRutinaPorFecha(fecha: evento.fecha));
    }
  }

  Future<void> _onModificarEjercicioRutina(
    ModificarEjercicioRutina evento, 
    Emitter<EstadoRutinas> emit,
) async {
    emit(const CargandoRutinas()); 
    
    try {
        final int idOriginal = evento.idEjercicioOriginal;
        final int idRutina = evento.idRutinaOriginal;
        
        // 1. Validar que tenemos IDs válidos para trabajar
        if (idOriginal <= 0 || idRutina <= 0) {
            throw Exception('IDs de rutina o ejercicio inválidos para la modificación.');
        }

        // --- A. Actualizar el Ejercicio (nombre y descripción) ---
        // Esto cambia la definición del ejercicio para TODAS las rutinas que lo usan.
        final int filasEjActualizadas = await _daoEjercicio.actualizarEjercicio(
            idEjercicio: idOriginal,
            nuevoNombre: evento.nuevoNombreEjercicio,
            nuevaDescripcion: evento.nuevaDescripcion,
        );
        
        if (filasEjActualizadas == 0) {
             // Esto puede ocurrir si el ejercicio fue eliminado antes por otro proceso,
             // aunque la rutina_ejercicio siga existiendo. Lanzamos error.
             throw Exception("No se pudo actualizar la definición del ejercicio (ID: $idOriginal).");
        }

        // --- B. Actualizar la Rutina_Ejercicio (repeticiones) ---
        // Esto solo afecta la rutina del día actual.
        final int filasREActualizadas = await _daoRutinaEjercicio.actualizarRepeticionesRutinaEjercicio(
            idRutina: idRutina,
            idEjercicio: idOriginal, // Usamos el ID original, ya que no cambió la FK
            nuevasRepeticiones: evento.nuevaRepeticiones,
        );

        if (filasREActualizadas == 0) {
             throw Exception("No se pudo actualizar la cantidad de repeticiones en la rutina.");
        }

        emit(const OperacionExitosa('Ejercicio modificado con éxito.'));
        
        // Recargar la lista para que se vean los cambios
        add(CargarRutinaPorFecha(fecha: evento.fechaRutina)); 

    } catch (e) {
        final String errorMsg = 'Error al modificar ejercicio: ${e.toString()}';
        emit(ErrorRutinas([], errorMsg));
        add(CargarRutinaPorFecha(fecha: evento.fechaRutina)); 
    }
}

//--------------ELIMINAR EJERCICIO DE RUTINA Y TMB RUTINA SI QUEDÓ VACÍA
Future<void> _onEliminarEjercicioDeRutina(
    EliminarEjercicioDeRutina evento, 
    Emitter<EstadoRutinas> emit,
) async {
    emit(const CargandoRutinas());
    
    try {
        // 1. Eliminar el registro de la tabla de unión (rutina_ejercicio)
        final int eliminados = await _daoRutinaEjercicio.eliminarEjercicioDeRutina(
            idRutina: evento.idRutina, 
            idEjercicio: evento.idEjercicio,
        );

        if (eliminados > 0) {
            // 2. Verificación y Limpieza: ¿La rutina quedó vacía?
            final int conteo = await _daoRutinas.contarEjerciciosEnRutina(evento.idRutina);
            
            if (conteo == 0) {
                // Si no quedan ejercicios, eliminamos la Rutina de la tabla 'rutinas'
                await _daoRutinas.eliminarRutina(evento.idRutina);
                
                // Opcional pero recomendado: Verificar si la indicación también queda vacía
                // Este paso puede ser complejo si la 'Indicacion' también contiene comidas.
                // Por simplicidad, por ahora solo eliminamos la Rutina vacía.
            }

            emit(OperacionExitosa('Ejercicio "${evento.nombreEjercicio}" eliminado.'));
        } else {
            emit(ErrorRutinas([], 'Advertencia: El ejercicio no fue encontrado para eliminar.'));
        }

        // 3. Recargar la rutina para actualizar la UI
        add(CargarRutinaPorFecha(fecha: evento.fechaActual));

    } catch (e) {
        final String errorMsg = 'Error al eliminar ejercicio: ${e.toString()}';
        print('BLoC CRITICAL ERROR: $errorMsg');
        emit(ErrorRutinas([], errorMsg));
        add(CargarRutinaPorFecha(fecha: evento.fechaActual));
    }
}

Future<void> _onEliminarRutinaCompleta(
    EliminarRutinaCompleta evento, 
    Emitter<EstadoRutinas> emit,
) async {
    emit(const CargandoRutinas());
    
    try {
        final int idRutina = evento.idRutina;
        
        // 1. Eliminar todos los registros de unión (rutina_ejercicio)
        // Necesitas un método en DaoRutinaEjercicio para esto.
        await _daoRutinaEjercicio.eliminarTodosEjerciciosDeRutina(idRutina);
        
        // 2. Eliminar la rutina principal (tabla 'rutinas')
        await _daoRutinas.eliminarRutina(idRutina);

        emit(const OperacionExitosa('Rutina completa eliminada con éxito.'));

        // 3. Recargar el día (mostrará el mensaje de que no hay rutina)
        add(CargarRutinaPorFecha(fecha: evento.fecha));

    } catch (e) {
        final String errorMsg = 'Error al eliminar la rutina: ${e.toString()}';
        print('BLoC CRITICAL ERROR: $errorMsg');
        emit(ErrorRutinas([], errorMsg));
        add(CargarRutinaPorFecha(fecha: evento.fecha));
    }
}

}