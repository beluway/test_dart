import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_dart/blocs/estados.dart';
import 'package:test_dart/dominio/dominios.dart';
import 'package:test_dart/blocs/eventos.dart';
import 'package:test_dart/daos/daos.dart';

class BlocComidas extends Bloc<EventoComidas,EstadoComidas> {

  BlocComidas() : super(CargandoComidas()) {
    // Aquí se pueden agregar los manejadores de eventos si es necesario
  }

  final DaoIndicaciones _daoIndicaciones = DaoIndicaciones();
  final DaoComidas _daoComidas = DaoComidas();


  Future<List<ComidaDetallada>> obtenerIndicacionComidaPorFecha(DateTime fecha) async {
    // 1. Obtener la Indicacion para esa fecha
    final indicacion = await _daoIndicaciones.obtenerIndicacionPorFecha(fecha);
    
    if (indicacion == null) {
      return []; // No hay indicación para esta fecha
    }

    // 2. Obtener la fecha de la indicación en el formato que espera ComidaDetallada
    // Asumimos que tu clase Indicacion tiene un campo DateTime llamado 'fecha'.
    // Usamos el formato String ISO 'YYYY-MM-DD'
    final String fechaString = indicacion.fecha.toIso8601String().split('T').first;

    // 3. Obtener los MAPAS de la tabla 'comidas' usando el ID de la indicación
    final List<Map<String, Object?>> mapasComidas = 
      await _daoComidas.obtenerComidasPorIndicacion(indicacion.id); 

    if (mapasComidas.isEmpty) {
      return []; // No hay comidas asociadas
    }

    // 4. Transformar y Combinar los datos (Mapeo a ComidaDetallada)
    final List<ComidaDetallada> listaComidasDetalladas = mapasComidas.map((mapa) {
      // Necesitas asegurarte de que tu tabla 'comidas' tenga un campo 'nombre'
      // o que puedas derivar el nombre desde 'descripcion'.
      
      // Creamos un nuevo mapa temporal con el campo 'fecha' añadido
      Map<String, Object?> mapaDetallado = Map.from(mapa);
      mapaDetallado['fecha'] = fechaString; // Añadimos la fecha de la indicación

      // Mapeamos el mapa combinado a ComidaDetallada
      return ComidaDetallada.fromMap(mapaDetallado);
    }).toList();
    
    // Opcional: Ordenar por hora
    listaComidasDetalladas.sort((a, b) => a.hora.compareTo(b.hora));

    return listaComidasDetalladas;
  }
}