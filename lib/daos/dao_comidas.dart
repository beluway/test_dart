import 'package:test_dart/daos/base_datos.dart';
import 'package:test_dart/dominio/dominios.dart';
import 'package:sqflite/sqlite_api.dart';

class DaoComidas {

  static final DaoComidas _instancia = DaoComidas._inicializar();

  DaoComidas._inicializar();

  factory DaoComidas() {
    return _instancia;
  }

  Future<List<Map<String, Object?>>> obtenerComidasPorIndicacion(int idIndicacion) async {
    Database bd = await BaseDatos().obtenerBaseDatos();

    List<Map<String, Object?>> mapas = await bd.query(
      'comidas',
      where: 'id_indicacion = ?',
      whereArgs: [idIndicacion],
    );
    // Devolvemos los mapas crudos. La transformación ocurre en el BLoC.
    return mapas;
  }
}