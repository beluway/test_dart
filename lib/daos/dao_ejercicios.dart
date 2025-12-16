import 'package:test_dart/daos/base_datos.dart';
import 'package:test_dart/dominio/dominios.dart';
import 'package:sqflite/sqlite_api.dart';

class DaoEjercicios {

  static final DaoEjercicios _instancia = DaoEjercicios._inicializar();

  DaoEjercicios._inicializar();

  factory DaoEjercicios() {
    return _instancia;
  }

  Future<List<Ejercicio>> listarEjercicios() async {
    Database bd = await BaseDatos().obtenerBaseDatos();

    List<Map<String, Object?>> mapas = await bd.query('ejercicios');

    return mapas.map((m) => Ejercicio.fromMap(m)).toList();
  }

  Future<Ejercicio?> obtenerEjercicio(int id) async {
    Database bd = await BaseDatos().obtenerBaseDatos();

    List<Map<String, Object?>> mapas = await bd.query(
      'ejercicios',
      where: 'id = ?',
      whereArgs: [id],
    );

    return mapas.isNotEmpty ? Ejercicio.fromMap(mapas.first) : null;
  }

  // ============================
  // INSERTAR EJERCICIO
  // ============================
  Future<int> insertarEjercicio(Ejercicio ejercicio) async {
    Database bd = await BaseDatos().obtenerBaseDatos();

    return await bd.insert(
      'ejercicios',
      ejercicio.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ============================
  // ACTUALIZAR EJERCICIO
  // ============================
  Future<int> actualizarEjercicio(Ejercicio ejercicio) async {
    Database bd = await BaseDatos().obtenerBaseDatos();

    return await bd.update(
      'ejercicios',
      ejercicio.toMap(),
      where: 'id = ?',
      whereArgs: [ejercicio.id],
    );
  }

  // ============================
  // ELIMINAR EJERCICIO
  // ============================
  Future<int> eliminarEjercicio(int id) async {
    Database bd = await BaseDatos().obtenerBaseDatos();

    return await bd.delete(
      'ejercicios',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Busca el ID de un ejercicio por su nombre, ignorando mayúsculas/minúsculas.
    /// Retorna el ID si lo encuentra, o null si no existe.
    Future<int?> obtenerIdPorNombre(String nombre) async {
        Database bd = await BaseDatos().obtenerBaseDatos();
        
        // Usamos LOWER() en SQL para asegurar una comparación sin distinción de mayúsculas
        final List<Map<String, dynamic>> resultados = await bd.query(
            'ejercicios',
            columns: ['id'],
            where: 'LOWER(nombre) = LOWER(?)',
            whereArgs: [nombre],
            limit: 1, // Solo necesitamos el primero
        );

        if (resultados.isNotEmpty) {
            // El ID es la clave primaria de la tabla 'ejercicios'
            return resultados.first['id'] as int;
        }
        return null;
    }

    /// Crea un nuevo ejercicio en la tabla 'ejercicios'.
    /// Retorna el ID de la fila insertada.
    Future<int> crearEjercicio(String nombre, String descripcion) async {
        Database bd = await BaseDatos().obtenerBaseDatos();
        
        final Map<String, Object?> valores = {
            'nombre': nombre,
            'descripcion': descripcion ?? descripcion : 'Descripción no provista por el usuario',
            // Agrega aquí cualquier otro campo que tu tabla 'ejercicios' requiera (ej. 'descripcion', 'tipo')
        };

        // El método `insert` de sqflite devuelve el ID de la fila insertada.
        final int idGenerado = await bd.insert(
            'ejercicios', 
            valores,
            conflictAlgorithm: ConflictAlgorithm.replace, 
        );
        
        return idGenerado;
    }

    
}