import 'package:intl/intl.dart';
import 'package:test_dart/daos/base_datos.dart';
import 'package:test_dart/dominio/dominios.dart';
import 'package:sqflite/sqlite_api.dart';

class DaoRutinas {

  static final DaoRutinas _instancia = DaoRutinas._inicializar();

  DaoRutinas._inicializar();

  factory DaoRutinas() {
    return _instancia;
  }

  Future<List<Rutina>> listarRutinas() async {
    Database bd = await BaseDatos().obtenerBaseDatos();

    List<Map<String, Object?>> mapas = await bd.query('rutinas');

    return mapas.map((m) => Rutina.fromMap(m)).toList();
  }

  Future<Rutina?> obtenerRutinaPorIdIndicacion(int idIndicacion) async {
    Database bd = await BaseDatos().obtenerBaseDatos();

    List<Map<String, Object?>> mapas = await bd.query(
      'rutinas',
      where: 'id_indicacion = ?',
      whereArgs: [idIndicacion],
    );
    return mapas.isNotEmpty ? Rutina.fromMap(mapas.first) : null;
  }

      Future<Rutina?> obtenerRutinaPorId(int idRutina)async{
      Database bd = await BaseDatos().obtenerBaseDatos();

      List<Map<String, Object?>> mapas = await bd.query(
        'rutinas',
        where: 'id = ?',
        whereArgs: [idRutina],
      );

      return mapas.isNotEmpty ? Rutina.fromMap(mapas.first) : null;
    }

Future<int?> obtenerIdRutinaPorFecha(DateTime fecha) async {

 Database bd = await BaseDatos().obtenerBaseDatos();

 // 1. Formatear la fecha para la consulta SQL (YYYY-MM-DD)
 final String fechaNormalizada = DateFormat('yyyy-MM-dd').format(fecha);

 final String sql = '''
            SELECT R.id 
            FROM rutinas AS R
            INNER JOIN indicaciones AS I ON R.id_indicacion = I.id
            WHERE strftime('%Y-%m-%d', I.fecha) = ?;
        ''';

 // 2. Ejecutar la consulta
 final List<Map<String, Object?>> resultados = await bd.rawQuery(
 sql,
 [fechaNormalizada] // El argumento de la fecha
 );
    
 // 3. Procesar el resultado:
    
 if (resultados.isNotEmpty) {
 // La lista contiene al menos un mapa (el ID de la rutina).
/*  final Map<String, Object?> primerResultado = resultados.first;
        
 // Extraemos el valor de la columna 'id' (que es R.id en tu SELECT)
 // Usamos (as int?) ?? null para manejar de forma segura si es nulo (aunque no debería serlo)
 return primerResultado['id'] as int?;  */
 return resultados.first['id'] as int;
 } else {
 // La lista está vacía, no hay rutina para esa fecha
 return null;
 }
}

Future<int> crearRutina({required int idIndicacion}) async {
    Database bd = await BaseDatos().obtenerBaseDatos();
    
    // 1. Prepara el mapa de valores a insertar.
    // La tabla 'rutinas' solo necesita el id de la Indicacion como FK.
    final Map<String, Object?> valores = {
        'id_indicacion': idIndicacion,
        // Si tu tabla 'rutinas' tiene más campos (ej. nombre, descripción), añádelos aquí.
    };

    // 2. Inserta la nueva rutina.
    // El método `insert` devuelve el ID de la fila recién insertada (el id de la Rutina).
    final int idRutinaGenerado = await bd.insert(
        'rutinas', 
        valores,
        // Usamos conflictAlgorithm.fail ya que no debería haber conflicto si 
        // la Indicacion es nueva.
        conflictAlgorithm: ConflictAlgorithm.fail,
    );
    
    return idRutinaGenerado;
}


}