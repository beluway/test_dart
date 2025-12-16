import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_dart/blocs/estados_rutinas.dart';
import 'package:test_dart/blocs/evento_rutinas.dart';
import 'package:test_dart/daos/daos.dart';

// Definición de Clases Auxiliares (mover a 'evento_rutinas.dart' o similar)
class CargarRutinaPorFecha extends EventoRutinas {
  final DateTime fecha;
  const CargarRutinaPorFecha({required this.fecha});
  @override
  List<Object?> get props => [fecha];
}

class BlocRutinas extends Bloc<EventoRutinas, EstadoRutinas> {
  // Uso de final para las dependencias para garantizar inmutabilidad
  final DaoRutinaEjercicio _daoRutinaEjercicio = DaoRutinaEjercicio();
  final DaoEjercicios _daoEjercicio = DaoEjercicios();

  BlocRutinas() : super(const CargandoRutinas()) {
    // Registro de manejadores de eventos
    on<CargarRutinaPorFecha>(_onCargarRutinaPorFecha);
    on<AgregarEjercicioARutina>(_onAgregarEjercicioARutina);
    on<AgregarEjercicioPorNombre>(_onAgregarEjercicioPorNombre);
    on<ModificarEjercicioRutina>(_onModificarEjercicioRutina);
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
        // --- 1. Obtener o Crear el ID del nuevo Ejercicio ---
        int? nuevoIdEjercicio = 
            await _daoEjercicio.obtenerIdPorNombre(evento.nuevoNombreEjercicio);

        // Si no existe, lo creamos.
        nuevoIdEjercicio ??= await _daoEjercicio.crearEjercicio(
            evento.nuevoNombreEjercicio, 
            descripcion: '', // Asume que la descripción se maneja en el DAO o es vacía
        );
        
        if (nuevoIdEjercicio == null || nuevoIdEjercicio <= 0) {
            throw Exception('No se pudo obtener el ID del nuevo ejercicio.');
        }

        // --- 2. Determinar la operación en la tabla rutina_ejercicio ---
        if (nuevoIdEjercicio == evento.idEjercicioOriginal) {
            // A) Si el Ejercicio NO CAMBIÓ (Solo Repeticiones)
            // Actualizamos la repetición del registro existente.
            await _daoRutinaEjercicio.actualizarRepeticionesRutinaEjercicio(
                idRutina: evento.idRutinaOriginal,
                idEjercicio: nuevoIdEjercicio,
                nuevasRepeticiones: evento.nuevaRepeticiones,
            );
        } else {
            // B) Si el Ejercicio SÍ CAMBIÓ (Repeticiones y Ejercicio)
            // 1. Eliminamos el registro antiguo (id_rutina, id_ejercicio_original)
            await _daoRutinaEjercicio.eliminarEjercicioDeRutina(
                idRutina: evento.idRutinaOriginal,
                idEjercicio: evento.idEjercicioOriginal,
            );

            // 2. Insertamos el nuevo registro (id_rutina, nuevo_id_ejercicio)
            await _daoRutinaEjercicio.anadirEjercicioARutinaConFecha(
                fecha: evento.fechaRutina,
                idEjercicio: nuevoIdEjercicio,
                repeticiones: evento.nuevaRepeticiones,
            );
        }

        emit(const OperacionExitosa('Ejercicio modificado con éxito.'));
        
        // Recargar la rutina para mostrar los cambios
        add(CargarRutinaPorFecha(fecha: evento.fechaRutina));

    } catch (e) {
        final String errorMsg = 'Error al modificar ejercicio: ${e.toString()}';
        emit(ErrorRutinas([], errorMsg));
        // Recargar para quitar el loading
        add(CargarRutinaPorFecha(fecha: evento.fechaRutina)); 
    }
}
}