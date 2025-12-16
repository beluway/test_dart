import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_dart/blocs/estados_rutinas.dart';
import 'package:test_dart/blocs/evento_rutinas.dart';
import 'package:test_dart/daos/daos.dart';

class BlocRutinas extends Bloc<EventoRutinas,EstadoRutinas> {

  final DaoRutinaEjercicio _daoRutinaEjercicio = DaoRutinaEjercicio();

  // 1. Definir la dependencia al DAO de Ejercicios
final DaoEjercicios _daoEjercicio = DaoEjercicios(); 
// Asume que DaoEjercicio existe y puede buscar/crear ejercicios

  BlocRutinas() : super(const CargandoRutinas()) {
    // Aquí se pueden agregar los manejadores de eventos si es necesario
    on<CargarRutinaPorFecha>(_onCargarRutinaPorFecha);
    on<AgregarEjercicioARutina>(_onAgregarEjercicioARutina);
    on<AgregarEjercicioPorNombre>(_onAgregarEjercicioPorNombre); // 👈 Nuevo manejador
  }
  
   Future<void> _onCargarRutinaPorFecha(
        CargarRutinaPorFecha evento, // <--- El tipo aquí DEBE ser CargarRutinaPorFecha
        Emitter<EstadoRutinas> emit,
    ) async {
        emit(const CargandoRutinas());
        try {
            // 3. Ya puedes acceder directamente a evento.fecha
            final List<Map<String,Object?>> rutina = 
                await _daoRutinaEjercicio.obtenerRutinaCompletaPorFecha(evento.fecha);
            
            if(rutina.isNotEmpty){
              emit(ExitoRutinas(rutina, 'Rutina Cargada.'));
            } else {
              emit(const ExitoRutinas([], 'No hay rutina programada para este día.'));
            }

        } catch (e) {
            /* emit(ErrorListarRutinas()); */
            emit(const ErrorRutinas([], 'Error al cargar la rutina.')); // Asegúrate de manejar la lista vacía aquí
        }
    }

    // 3. Implementación del nuevo manejador:
Future<void> _onAgregarEjercicioPorNombre(
    AgregarEjercicioPorNombre evento, 
    Emitter<EstadoRutinas> emit,
) async {
    // ⚠️ SOLUCIÓN CARGA INFINITA: Emitir cargando antes y recargar al final
    // Esto asegura que la UI sepa que algo está pasando.
    emit(const CargandoRutinas()); 
    
    try {
        // --- LÓGICA DE BÚSQUEDA/CREACIÓN DE EJERCICIO ---
        
        // 1. Buscar o crear el ejercicio
        int? idEjercicio = await _daoEjercicio.obtenerIdPorNombre(evento.nombreEjercicio);
        
        if (idEjercicio == null) {
            // 2. Si no existe, crearlo y obtener el ID generado
            idEjercicio = await _daoEjercicio.crearEjercicio(evento.nombreEjercicio);
        }

        if (idEjercicio == null) {
            throw Exception('No se pudo obtener o crear el ID del ejercicio.');
        }

        // --- LÓGICA DE BÚSQUEDA/CREACIÓN DE RUTINA ---
        // 3. Reutilizar la lógica unificada del DAO (creará rutina si no existe)
        await _daoRutinaEjercicio.anadirEjercicioARutinaConFecha(
            fecha: evento.fecha,
            idEjercicio: idEjercicio,
            repeticiones: evento.repeticiones,
        );
        
        // 4. Recargar la rutina para actualizar la UI
        // Este evento disparará _onCargarRutinaPorFecha que EMITIRÁ ExitoRutinas.
        add(CargarRutinaPorFecha(fecha: evento.fecha));

    } catch (e) {
        // 5. Si hay error, EMITIMOS el estado de error
        emit(ErrorRutinas([], 'Error al añadir el ejercicio: ${e.toString()}'));
        // Y recargamos los datos anteriores por si el fallo no fue destructivo
        add(CargarRutinaPorFecha(fecha: evento.fecha)); 
    }
}

    Future<void> _onAgregarEjercicioARutina(
    AgregarEjercicioARutina evento, 
    Emitter<EstadoRutinas> emit,
) async {
    try {
        // Llama a la lógica unificada del DAO que maneja la creación de Rutina
        await _daoRutinaEjercicio.anadirEjercicioARutinaConFecha(
            fecha: evento.fecha,
            idEjercicio: evento.idEjercicio,
            repeticiones: evento.repeticiones,
        );
        
        // 1. Emitir un estado de éxito
        emit(const OperacionExitosa('Ejercicio añadido a la rutina con éxito.'));
        
        // 2. Recargar la rutina para actualizar la UI (Muy importante)
        add(CargarRutinaPorFecha(fecha: evento.fecha));

    } catch (e) {
        emit(ErrorRutinas([], 'Error al añadir el ejercicio: ${e.toString()}'));
        // Si falla la inserción, es mejor intentar recargar la rutina anterior por si acaso
        add(CargarRutinaPorFecha(fecha: evento.fecha)); 
    }
}

}

// ⚠️ Recordatorio: Define tu evento CargarRutinaPorFecha si aún no lo has hecho:
class CargarRutinaPorFecha extends EventoRutinas {
  final DateTime fecha;
  const CargarRutinaPorFecha({required this.fecha});
}

