import 'package:intl/intl.dart';
import 'package:test_dart/daos/base_datos.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:test_dart/daos/daos.dart';
import 'package:test_dart/dominio/rutina_ejercicio.dart';

class DaoRutinaEjercicio {

  static final DaoRutinaEjercicio _instancia = DaoRutinaEjercicio._inicializar();

  final DaoIndicaciones _daoIndicaciones = DaoIndicaciones();
  final DaoRutinas _daoRutinas = DaoRutinas();

  DaoRutinaEjercicio._inicializar();

  factory DaoRutinaEjercicio() {
    return _instancia;
  }
  Future<List<Map<String, Object?>>> obtenerRutinaCompletaPorFecha(DateTime fecha) async {
        Database bd = await BaseDatos().obtenerBaseDatos();
        
        // Formatear la fecha para la consulta SQL (YYYY-MM-DD)
        final String fechaNormalizada = DateFormat('yyyy-MM-dd').format(fecha);
        
        // 1. La consulta SQL con JOINS
          final String sql = '''
                  SELECT
                      E.nombre AS nombre_ejercicio,
                      E.descripcion AS descripcion_ejercicio,
                      RE.repeticiones,  
                      RE.id_rutina,
                      RE.id_ejercicio,
                      I.fecha AS fecha_indicacion
                  FROM
                      indicaciones AS I
                  INNER JOIN
                      rutinas AS R ON R.id_indicacion = I.id
                  INNER JOIN
                      rutina_ejercicio AS RE ON RE.id_rutina = R.id 
                  INNER JOIN
                      ejercicios AS E ON E.id = RE.id_ejercicio
                  WHERE
                      strftime('%Y-%m-%d', I.fecha) = ?;
              ''';

        // 2. Ejecutar la consulta cruda (rawQuery)
        final List<Map<String, Object?>> resultados = await bd.rawQuery(
            sql,
            [fechaNormalizada] // El argumento de la fecha para el '?' en el WHERE
        );

        /* // 3. Mapear los resultados a EjercicioDetallado
        if (resultados.isEmpty) {
            return []; // No hay rutina para esta fecha
        } */

        return resultados;
    }

    Future<List<RutinaEjercicio>> listarRutinaEjercicio()async{
      Database bd = await BaseDatos().obtenerBaseDatos();

      List <Map<String,Object?>> mapasRutinaEjercicios = (await bd.query('rutina_ejercicio')).map((mre) => {...mre}).toList();

      for(Map<String,Object?> mr in mapasRutinaEjercicios){
      mr ['rutinas'] = (await DaoRutinas().obtenerRutinaPorId(mr['id_rutina'] as int)) ?.toMap();
      }

      for(Map<String,Object?> me in mapasRutinaEjercicios){
      me ['ejercicios'] = (await DaoEjercicios().obtenerEjercicio(me['id_ejercicio'] as int)) ?.toMap();
      }


    return mapasRutinaEjercicios.map((mre) => RutinaEjercicio.fromMap(mre)).toList();
  }

  Future<int> crearRutina({required int idIndicacion}) async {
    Database bd = await BaseDatos().obtenerBaseDatos();
    
    // La tabla 'rutinas' solo necesita el id de la Indicacion como FK
    final Map<String, Object?> valores = {
        'id_indicacion': idIndicacion,
        // Si tu tabla 'rutinas' tiene más campos, añádelos aquí.
    };

    // Usamos el método insert de sqflite.
    // El método `insert` devuelve el ID de la fila insertada (el id de la Rutina).
    final int idRutinaGenerado = await bd.insert(
        'rutinas', 
        valores,
        conflictAlgorithm: ConflictAlgorithm.fail,
    );
    
    return idRutinaGenerado;
}

// Método auxiliar que asume que existe en DaoRutinas (debes crearlo)
// Debería: SELECT R.id FROM rutinas R INNER JOIN indicaciones I ON R.id_indicacion = I.id WHERE strftime('%Y-%m-%d', I.fecha) = ?
Future<int?> _obtenerIdRutinaPorFecha(DateTime fecha) async {
    // ⚠️ IMPLEMENTAR ESTO EN DaoRutinas o un DAO de alto nivel 
    // Por ahora, asumimos que devuelve el ID de Rutina o null.
    return await _daoRutinas.obtenerIdRutinaPorFecha(fecha); 
}

// Método auxiliar que asume que existe en DaoIndicacion (debes crearlo)
Future<int> _crearIndicacion(DateTime fecha) async {
    // ⚠️ IMPLEMENTAR ESTO EN DaoIndicacion. Inserta en 'indicaciones'.
    // Retorna el ID de la nueva Indicación.
    return await _daoIndicaciones.crearIndicacion(fecha: fecha);
}

// Método auxiliar que asume que existe en DaoRutinas (debes crearlo)
Future<int> _crearRutina(int idIndicacion) async {
    // ⚠️ IMPLEMENTAR ESTO EN DaoRutinas. Inserta en 'rutinas'.
    // Retorna el ID de la nueva Rutina.
    return await _daoRutinas.crearRutina(idIndicacion: idIndicacion);
}


  Future<void> anadirEjercicioARutinaConFecha({
    required DateTime fecha, 
    required int idEjercicio,
    required int repeticiones, 
}) async {
    Database bd = await BaseDatos().obtenerBaseDatos();
    
    final DateTime fechaNormalizada = DateTime(fecha.year, fecha.month, fecha.day);
    
    int? idRutina = await _obtenerIdRutinaPorFecha(fechaNormalizada);
    
    if (idRutina == null) {
        // La rutina no existe, creamos Indicacion y Rutina
        
        // ❌ Eliminamos bd.transaction((txn) async { ... })

        // A. Crear la Indicación
        final int idIndicacion = await _crearIndicacion(fechaNormalizada);
        print('ID Indicacion generado: $idIndicacion'); // <-- Depuración
        
        // B. Crear la Rutina, enlazándola con la Indicación
        idRutina = await _crearRutina(idIndicacion); // ✅ Ahora idRutina se asigna correctamente.
        
    }

    if (idRutina <= 0) { // ⚠️ Chequeo de ID válido (> 0)
        throw Exception("Error crítico: El ID de la Rutina no fue creado correctamente.");
    }

    // 2. Insertar el Ejercicio en rutina_ejercicio
    final RutinaEjercicio nuevoRegistro = RutinaEjercicio(
        idRutina: idRutina!, // Usamos el ID de la rutina creado/encontrado
        idEjercicio: idEjercicio, 
        repeticiones: repeticiones, 
    );
    
    await bd.insert(
        'rutina_ejercicio',
        nuevoRegistro.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
    );
}


    }
