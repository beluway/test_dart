import 'package:intl/intl.dart';
import 'package:test_dart/daos/base_datos.dart';
import 'package:test_dart/dominio/dominios.dart';
import 'package:sqflite/sqlite_api.dart';

class DaoIndicaciones {

  static final DaoIndicaciones _instancia = DaoIndicaciones._inicializar();

  DaoIndicaciones._inicializar();

  factory DaoIndicaciones() {
    return _instancia;
  }

  Future<List<Indicacion>> listarIndicaciones() async {
    Database bd = await BaseDatos().obtenerBaseDatos();

    List<Map<String, Object?>> mapas = await bd.query(
      'indicaciones',
      orderBy: 'fecha ASC',
    );

    return mapas.map((m) => Indicacion.fromMap(m)).toList();
  }

  Future<Indicacion?> obtenerIndicacion(int id) async {
    Database bd = await BaseDatos().obtenerBaseDatos();

    List<Map<String, Object?>> mapas = await bd.query(
      'indicaciones',
      where: 'id = ?',
      whereArgs: [id],
    );

    return mapas.isNotEmpty ? Indicacion.fromMap(mapas.first) : null;
  }

  // NUEVO MÉTODO: Obtener Indicacion por fecha (solo la parte de fecha, sin tiempo)
  Future<Indicacion?> obtenerIndicacionPorFecha(DateTime fecha) async {
    Database bd = await BaseDatos().obtenerBaseDatos();
    

    String fechaNormalizada = DateFormat('yyyy-MM-dd').format(fecha); 

    List<Map<String, Object?>> mapas = await bd.query(
      'indicaciones',
      where: "strftime('%Y-%m-%d', fecha) = ?", // Comparamos solo la parte de la fecha
      whereArgs: [fechaNormalizada],
    );

    return mapas.isNotEmpty ? Indicacion.fromMap(mapas.first) : null;
  }

  Future<int> crearIndicacion({required DateTime fecha}) async {
    Database bd = await BaseDatos().obtenerBaseDatos();
    
    /* // Normalizar la fecha y formatearla para asegurar consistencia en la DB
    final DateTime fechaNormalizada = DateTime(fecha.year, fecha.month, fecha.day);
    final String fechaFormateada = DateFormat('yyyy-MM-dd').format(fechaNormalizada); */
    // ⚠️ CLAVE: Formatear la fecha a un string consistente para SQLite
        final String fechaString = DateFormat('yyyy-MM-dd').format(fecha);
    
    final Map<String, Object?> valores = {
        'fecha': fechaString,
        // No necesitamos hora ni otros campos si no existen en tu modelo
    };

    // Usamos el método insert de sqflite.
    // El método `insert` devuelve el ID de la fila insertada.
    final int idGenerado = await bd.insert(
        'indicaciones', 
        valores,
        conflictAlgorithm: ConflictAlgorithm.fail, // No debería existir si es una nueva indicación
    );
    
    return idGenerado;
}

}