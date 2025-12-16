
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BaseDatos {

  static final BaseDatos _instancia = BaseDatos._inicializar();

  Database? _baseDatos;

  BaseDatos._inicializar();

    factory BaseDatos(){
    return _instancia;
  }

   Future<Database> obtenerBaseDatos() async {
    if(_baseDatos !=null) return _baseDatos!;

  //path donde se guardan todas las bases de datos de mi aplicación
  final String rutaDirectorioBDs = await getDatabasesPath();
  final String rutaArchivoBD = join(rutaDirectorioBDs, 'bios_training.sqlite');

  _baseDatos = await openDatabase(
    rutaArchivoBD,
    version: 1,
    onCreate: (db, version) async { //se ejecuta la primera vez que creo mi bd
    //si yo no le pongo await y mnando varios excecute no controlo el orden
     await db.execute('''
      CREATE TABLE indicaciones (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      fecha TEXT NOT NULL
      );
      ''');
      await db.execute('''
      CREATE TABLE rutinas (
      id INTEGER NOT NULL  PRIMARY KEY AUTOINCREMENT,
      id_indicacion INTEGER NOT NULL,
      FOREIGN KEY (id_indicacion) REFERENCES indicaciones(id) ON DELETE CASCADE
      );
      ''');
      await db.execute('''
      CREATE TABLE comidas (
      id_indicacion INTEGER NOT NULL PRIMARY KEY,
      hora TEXT NOT NULL,
      descripcion TEXT NOT NULL,
      FOREIGN KEY (id_indicacion) REFERENCES indicaciones(id)
      );
      ''');
            await db.execute('''
      CREATE TABLE ejercicios (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL,
      descripcion TEXT NOT NULL
      );
      ''');

        await db.execute('''
        CREATE TABLE rutina_ejercicio (

        id_rutina INTEGER NOT NULL , 
        id_ejercicio INTEGER NOT NULL,
        repeticiones INTEGER NOT NULL,
        PRIMARY KEY (id_rutina, id_ejercicio),
        FOREIGN KEY (id_rutina) REFERENCES rutinas(id),
        FOREIGN KEY (id_ejercicio) REFERENCES ejercicios(id)
        );
      ''');

      await db.execute('''
      INSERT INTO indicaciones
      VALUES
        (NULL, '2025-01-10'),
        (NULL, '2025-01-11'),
        (NULL, '2025-01-12'),
        (NULL, '2025-01-15');
      ''');

      await db.execute('''
      INSERT INTO rutinas
      VALUES
        (NULL,1),
        (NULL,2),
        (NULL,3),
        (NULL,4);
      ''');

      await db.execute('''
      INSERT INTO comidas 
      VALUES
        (1, '08:00', 'Desayuno: Avena con fruta y yogurt.'),
        (2, '12:30', 'Almuerzo: Pollo grillado con ensalada.'),
        (3, '20:00', 'Cena: Tortilla de huevo y vegetales.'),
        (4, '21:00', 'Snack: Pipocas.');
      ''');

      await db.execute('''
      INSERT INTO ejercicios
      VALUES
      (NULL, 'Flexiones', 'Ejercicio de pecho con peso corporal.'),
      (NULL, 'Sentadillas', 'Sentadilla tradicional sin peso.'),
      (NULL, 'Plancha', 'Plancha abdominal estática.'),
      (NULL, 'Burpees', 'Ejercicio completo con salto.'),
      (NULL, 'Abdominales', 'Crunch abdominal clásico.'),
      (NULL, 'Estocadas', 'Lunges alternados hacia adelante.');
      ''');

          await db.execute('''
      INSERT INTO rutina_ejercicio
      VALUES
      (1, 1, 12),
      (1, 2, 20),
      (1, 3, 30),
      (1, 5, 25),
      (2, 4, 10),
      (2, 2, 25),
      (2, 3, 40),
      (2, 6, 20),
      (3, 1, 15),
      (3, 4, 8),
      (3, 5, 30),
      (3, 6, 31),
      (4, 1, 10),
      (4, 2, 18),
      (4, 6, 15),
      (4, 5, 30);
      ''');

    },
    onOpen: (db) async {//cuando se abara exitosamente la bd voy a ejecutar este comando
    // En SQLite, las restricciones de claves foráneas están deshabilitadas de manera predeterminada por cuestiones de retrocompatibilidad.
    // Para habilitarlas en la conexión actual:
      await db.execute('PRAGMA foreign_keys = ON;');
    },
  );

  return _baseDatos!;
  }

    Future<void> cerrarBaseDatos() async {
    //si no es nullo llamo al método close
    await _baseDatos?.close();

    _baseDatos = null;
  }
}