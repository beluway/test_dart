
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_dart/blocs/bloc_rutinas.dart';
import 'package:test_dart/blocs/estados_rutinas.dart';
import 'package:test_dart/blocs/evento_rutinas.dart';
import 'package:test_dart/widgets/calendar.dart';
// import 'package:test_dart/widgets/dialogo_gestion_ejercicio.dart'; // Comentado si ya no se usa

class GestionRutinaEjercicioTab extends StatefulWidget {
  const GestionRutinaEjercicioTab({super.key});

  @override
  State<GestionRutinaEjercicioTab> createState() => GestionRutinaEjercicioTabState();
}

class GestionRutinaEjercicioTabState extends State<GestionRutinaEjercicioTab> {
  DateTime _fechaActual = DateTime.now();


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarRutina(_fechaActual);
    });
  }

  // ===================== LÓGICA BLoC =====================

  /// Dispara el evento CargarRutinaPorFecha
  void _cargarRutina(DateTime fecha) {
    BlocProvider.of<BlocRutinas>(context).add(CargarRutinaPorFecha(fecha:fecha));
  }

  void _actualizarFecha(DateTime nuevaFecha) {
    setState(() {
      _fechaActual = nuevaFecha;
    });
    _cargarRutina(nuevaFecha);
  }

  //----------------MUESTRA EL DIALOGO PARA AÑADIR/MODIFICAR EJERCICIO

 Future<void> _mostrarDialogoEjercicio(Map<String, dynamic>? ejercicioExistente) async {
    // ⚠️ Importante: Usaremos 'nombre' y no 'id' para la lógica del DAO.
    TextEditingController nombreEjercicioController = TextEditingController();
    TextEditingController repeticionesController = TextEditingController();
    TextEditingController descripcionController = TextEditingController();
    
    // Si estamos editando, pre-cargamos los valores
    if (ejercicioExistente != null) {
        final String nombreEjercicio = (ejercicioExistente['nombre_ejercicio'] as String?) ?? '';
        final int repeticiones = (ejercicioExistente['repeticiones'] as int?) ?? 0;
        final String descripcionEjercicio = (ejercicioExistente['descripcion_ejercicio'] as String?) ?? '';

        nombreEjercicioController.text = nombreEjercicio;
        repeticionesController.text = repeticiones.toString();
        descripcionController.text = descripcionEjercicio;
    }

    await showDialog(
        context: context,
        builder: (context) {
            return AlertDialog(
                title: Text(ejercicioExistente == null ? 'Añadir Nuevo Ejercicio' : 'Editar Ejercicio'),
                content: SingleChildScrollView(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            // 1. Input de Texto para el Nombre del Ejercicio (Nuevo)
                            TextFormField(
                                controller: nombreEjercicioController,
                                decoration: const InputDecoration(
                                    labelText: 'Nombre del Ejercicio',
                                    border: OutlineInputBorder(),
                                ),
                            ),
                            const SizedBox(height: 20),
                            
                            // 2. Input de Repeticiones
                            TextFormField(
                                controller: repeticionesController,
                                decoration: const InputDecoration(
                                    labelText: 'Repeticiones',
                                    border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 20),
                              // 2. Input de descripción
                            TextFormField(
                                controller: descripcionController,
                                decoration: const InputDecoration(
                                    labelText: 'Descripción',
                                    border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.text,
                            ),
                        ],
                    ),
                ),
                actions: [
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                        onPressed: () {
                            final String nombreEjercicio = nombreEjercicioController.text.trim();
                            final int? repeticiones = int.tryParse(repeticionesController.text);
                            final String descripcion = descripcionController.text.trim();

                            if (nombreEjercicio.isEmpty || repeticiones == null || repeticiones <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Ingrese un nombre y repeticiones válidas.')),
                                );
                                return;
                            }

                            Navigator.of(context).pop(); // Cerrar el diálogo

                            // Lógica para AÑADIR o EDITAR
                            if (ejercicioExistente == null) {
                                // ➡️ AÑADIR: Ahora pasamos el NOMBRE y las repeticiones
                                _anadirEjercicioPorNombre(nombreEjercicio, repeticiones, descripcion);
                            } else {
                                // ➡️ EDITAR: Mantenemos la lógica de edición
                                _editarEjercicioPorNombre(nombreEjercicio, repeticiones,descripcion ,ejercicioExistente);
                            }
                        },
                        child: Text(ejercicioExistente == null ? 'Añadir' : 'Guardar'),
                    ),
                ],
            );
        },
    );
}

void _anadirEjercicioPorNombre(String nombre, int repeticiones, String descripcion) {
    // 1. Feedback inicial (antes del BLoC)
    ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(content: Text('Procesando: $nombre...')),
 );
    
    // 2. Llamar al BLoC con el nuevo evento y parámetros
    BlocProvider.of<BlocRutinas>(context).add(
        AgregarEjercicioPorNombre(
            fecha: _fechaActual, 
            nombreEjercicio: nombre, // Nuevo parámetro
            repeticiones: repeticiones,
            descripcion: descripcion,
        )
    );
}

//------------------------EDITAR EJERCICIO----------------------------------
void _editarEjercicioPorNombre(
    String nuevoNombre, 
    int nuevasRepeticiones,
    String nuevaDescripcion,
    Map<String, dynamic> datosOriginales // Contiene id_rutina e id_ejercicio originales
) {
    // ⚠️ Se necesitan los IDs originales para la clave compuesta de la DB
    final int idRutinaOriginal = (datosOriginales['id_rutina'] as int?) ?? 0;
    final int idEjercicioOriginal = (datosOriginales['id_ejercicio'] as int?) ?? 0;

    if (idRutinaOriginal == 0 || idEjercicioOriginal == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: No se encontraron los IDs originales para la edición.')),
        );
        return;
    }

    // 1. Disparar el evento de MODIFICACIÓN
    BlocProvider.of<BlocRutinas>(context).add(
        ModificarEjercicioRutina(
            idRutinaOriginal: idRutinaOriginal, // ID de la rutina donde está el ejercicio
            idEjercicioOriginal: idEjercicioOriginal, // ID del ejercicio que se va a modificar/reemplazar
            nuevoNombreEjercicio: nuevoNombre, // El nuevo nombre (puede ser el mismo)
            nuevaRepeticiones: nuevasRepeticiones, // Las nuevas repeticiones
            nuevaDescripcion: nuevaDescripcion, // La nueva descripción
            fechaRutina: _fechaActual, // Para recargar la lista
        )
    );
    
    // 2. Feedback
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Guardando cambios para $nuevoNombre...')),
    );
}


  /// Dispara el evento EliminarEjercicioDeRutina
  void _confirmarEliminacion(int idRutina,int idEjercicio, String nombreEjercicio) {
    // 1. Disparamos el evento de eliminación
    BlocProvider.of<BlocRutinas>(context).add(
      EliminarEjercicioDeRutina(
        idRutina: idRutina,
        idEjercicio :idEjercicio,
        nombreEjercicio : nombreEjercicio,
        fechaActual: _fechaActual, // Para recargar el estado
      ),
    );

    // 2. Feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Eliminando: $nombreEjercicio...')),
    );
  }

  // ===================== UI BLoC =====================

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SelectorFecha(onDateSelected: _actualizarFecha),
        const Divider(),

              Expanded(
            child: BlocListener<BlocRutinas,EstadoRutinas>(
              listener: (context, state) {
                if (state is OperacionExitosa) {
                // Muestra éxito
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.mensaje ?? 'Operación exitosa')),
                );
              } else if (state is ErrorRutinas) {
                // Muestra error
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('FALLÓ: ${state.mensaje}')),
                );
              }
              },
              child: BlocBuilder<BlocRutinas, EstadoRutinas>(
            builder: (context, state) {
            if (state is CargandoRutinas) {
            return const Center(child: CircularProgressIndicator());
            }
            if (state is ErrorRutinas) {
            return Center(child: Text('Error: ${state.mensaje ?? 'Error de carga'}'));
            }
            
                if (state is ExitoRutinas) {
            final List<Map<String, dynamic>> ejercicios = state.ejercicios; 
                
                // 1. Lógica para determinar el texto del botón
                final String buttonLabel = ejercicios.isEmpty
                    ? 'Crear Rutina y Añadir Ejercicio' 
                    : 'Añadir Ejercicio'; 

                // 2. El botón dinámico (fuera del ListView para que siempre se vea)
                final Widget actionButton = Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(// Usamos un Row para agrupar el botón Añadir y Eliminar
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                        onPressed: () => _mostrarDialogoEjercicio(null), 
                        icon: const Icon(Icons.add),
                        label: Text(buttonLabel),
                    ),
                    // Botón ELIMINAR RUTINA COMPLETA (Solo si hay ejercicios)
            if (ejercicios.isNotEmpty)
                ElevatedButton.icon(
                    onPressed: () {
                        // Obtenemos el ID de la rutina del primer ejercicio
                        final int idRutinaAEliminar = (ejercicios.first['id_rutina'] as int?) ?? 0;
                        if (idRutinaAEliminar > 0) {
                            _mostrarDialogoConfirmacion(idRutinaAEliminar);
                        }
                    }, 
                    icon: const Icon(Icons.delete_sweep),
                    label: const Text('Eliminar Rutina'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Resaltar la acción destructiva
                    ),
                ),
                      ],
                    ),
                    
                    
                );
                
                // 3. Retornar el Column principal con el botón y el contenido
                return Column( 
                    children: [
                        actionButton, // El botón dinámico

                        // Contenido de la lista/mensaje
                        if (ejercicios.isEmpty)
                            Expanded( // Ocupa el espacio restante
                                child: Center(child: Text(state.mensaje ?? 'No hay ejercicios en la rutina para este día.')),
                            )
                        else
                            Expanded( // Ocupa el espacio restante cuando hay ejercicios
                                child: ListView.builder(
                                    itemCount: ejercicios.length,
                                    itemBuilder: (context, index) {
                                        final Map<String, dynamic> ejercicio = ejercicios[index];
                                        final int idRutina = (ejercicio['id_rutina'] as int?)?? 0;
                                        final int idEjercicio = (ejercicio['id_ejercicio'] as int?)?? 0;
                                        final String nombre = (ejercicio['nombre_ejercicio'] as String?) ?? 'Sin nombre'; 
                                        final int repeticiones = (ejercicio['repeticiones'] as int?)?? 0;
                                        final String descripcion = (ejercicio['descripcion_ejercicio'] as String?)?? 'Sin descripción.';

                                        return Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                            child: Card(
                                                child: ListTile(
                                                    leading: const Icon(Icons.fitness_center),
                                                    title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                                                    subtitle: Text('Repeticiones: $repeticiones Descripción: $descripcion'), 
                                                    
                                                    trailing: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                            IconButton(
                                                                icon: const Icon(Icons.edit, size: 20),
                                                                onPressed: () => _mostrarDialogoEjercicio(ejercicio), 
                                                            ),
                                                            IconButton(
                                                                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                                                onPressed: () => _confirmarEliminacion(idRutina, idEjercicio, nombre), 
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                        );
                                    },
                                ),
                            ),
                    ],
                );
 }
 
 return const Center(child: Text('Cargando la gestión de la rutina...'));
 },
 ),
              ),
            
            
 ),

      ],
    );
  }

  Future<void> _mostrarDialogoConfirmacion(int idRutina) async {
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
            title: const Text('Confirmar Eliminación'),
            content: const Text('¿Está seguro de que desea eliminar TODA la rutina de ejercicios para este día? Esta acción es irreversible.'),
            actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                ),
                ElevatedButton(
                    onPressed: () {
                        Navigator.of(context).pop();
                        // 🎯 Disparar la eliminación
                        BlocProvider.of<BlocRutinas>(context).add(
                            EliminarRutinaCompleta(
                                idRutina: idRutina,
                                fecha: _fechaActual,
                            ),
                        );
                        // El BlocListener se encargará del feedback.
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
                ),
            ],
        ),
    );
}
}


/* import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_dart/blocs/bloc_rutinas.dart';
import 'package:test_dart/blocs/estados_rutinas.dart';
import 'package:test_dart/blocs/evento_rutinas.dart';
import 'package:test_dart/widgets/calendar.dart';

class GestionRutinaEjercicioTab extends StatefulWidget {
  const GestionRutinaEjercicioTab({super.key});

  @override
  State<GestionRutinaEjercicioTab> createState() =>
      _GestionRutinaEjercicioTabState();
}

class _GestionRutinaEjercicioTabState
    extends State<GestionRutinaEjercicioTab> {
  DateTime _fechaActual = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarRutina(_fechaActual);
    });
  }

  // ===================== BLoC =====================

  void _cargarRutina(DateTime fecha) {
    context.read<BlocRutinas>().add(
          CargarRutinaPorFecha(fecha: fecha),
        );
  }

  void _actualizarFecha(DateTime nuevaFecha) {
    setState(() => _fechaActual = nuevaFecha);
    _cargarRutina(nuevaFecha);
  }

  void _anadirEjercicioPorNombre(String nombre, int repeticiones, String descripcion) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Procesando: $nombre...')),
    );

    context.read<BlocRutinas>().add(
          AgregarEjercicioPorNombre(
            fecha: _fechaActual,
            nombreEjercicio: nombre,
            repeticiones: repeticiones,
          ),
        );
  }

  void _confirmarEliminacion(
      int idRutina, int idEjercicio, String nombreEjercicio) {
    context.read<BlocRutinas>().add(
          EliminarEjercicioDeRutina(
            idRutina: idRutina,
            idEjercicio: idEjercicio,
            nombreEjercicio: nombreEjercicio,
            fechaActual: _fechaActual,
          ),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Eliminando: $nombreEjercicio...')),
    );
  }

  // ===================== DIALOGO =====================

  Future<void> _mostrarDialogoEjercicio(
      Map<String, dynamic>? ejercicioExistente) async {
    final nombreController = TextEditingController();
    final repeticionesController = TextEditingController();
    final descripcionController = TextEditingController();

    final focusNombre = FocusNode();
    final focusReps = FocusNode();
    final focusDesc = FocusNode();

    if (ejercicioExistente != null) {
      nombreController.text =
          (ejercicioExistente['nombre_ejercicio'] as String?) ?? '';
      repeticionesController.text =
          ((ejercicioExistente['repeticiones'] as int?) ?? 0).toString();
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            ejercicioExistente == null
                ? 'Añadir ejercicio'
                : 'Editar ejercicio',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // NOMBRE
                TextFormField(
                  controller: nombreController,
                  focusNode: focusNombre,
                  readOnly: ejercicioExistente != null,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(dialogContext)
                        .requestFocus(focusReps);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Nombre del ejercicio',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // REPETICIONES
                TextFormField(
                  controller: repeticionesController,
                  focusNode: focusReps,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(dialogContext)
                        .requestFocus(focusDesc);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Repeticiones',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // DESCRIPCIÓN
                TextFormField(
                  controller: descripcionController,
                  focusNode: focusDesc,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) {
                    FocusScope.of(dialogContext).unfocus();
                  },
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                FocusScope.of(dialogContext).unfocus();
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final nombre = nombreController.text.trim();
                final reps =
                    int.tryParse(repeticionesController.text);
                final descripcion = descripcionController.text.trim();

                if (nombre.isEmpty || reps == null || reps <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Complete los campos correctamente'),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext);

                if (ejercicioExistente == null) {
                  _anadirEjercicioPorNombre(nombre, reps, descripcion);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  // ===================== UI =====================

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SelectorFecha(onDateSelected: _actualizarFecha),
        const Divider(),
        Expanded(
          child: BlocBuilder<BlocRutinas, EstadoRutinas>(
            builder: (context, state) {
              if (state is CargandoRutinas) {
                return const Center(
                    child: CircularProgressIndicator());
              }

              if (state is ErrorRutinas) {
                return Center(
                  child:
                      Text(state.mensaje ?? 'Error cargando rutina'),
                );
              }

              if (state is ExitoRutinas) {
                final ejercicios = state.ejercicios;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _mostrarDialogoEjercicio(null),
                        icon: const Icon(Icons.add),
                        label: Text(
                          ejercicios.isEmpty
                              ? 'Crear rutina y añadir ejercicio'
                              : 'Añadir ejercicio',
                        ),
                      ),
                    ),
                    Expanded(
                      child: ejercicios.isEmpty
                          ? Center(
                              child: Text(
                                state.mensaje ??
                                    'No hay ejercicios para este día',
                              ),
                            )
                          : ListView.builder(
                              itemCount: ejercicios.length,
                              itemBuilder: (_, index) {
                                final e = ejercicios[index];

                                final idRutina =
                                    (e['id_rutina'] as int?) ?? 0;
                                final idEjercicio =
                                    (e['id_ejercicio'] as int?) ?? 0;
                                final nombre =
                                    (e['nombre_ejercicio']
                                            as String?) ??
                                        'Sin nombre';
                                final reps =
                                    (e['repeticiones'] as int?) ?? 0;
                                final descrip = (e['descripcion_ejercicio'] as String?) ?? 'Descripción no provista.';

                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 6),
                                  child: Card(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.fitness_center,
                                            size: 32,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                              children: [
                                                Text(
                                                  nombre,
                                                  style:
                                                      const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(
                                                    height: 6),
                                                Text(
                                                    'Repeticiones: $reps'),
                                                    const SizedBox(height: 6),
                                                    Text('Descripción: $descrip'),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.edit),
                                                onPressed: () =>
                                                    _mostrarDialogoEjercicio(
                                                        e),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () =>
                                                    _confirmarEliminacion(
                                                        idRutina,
                                                        idEjercicio,
                                                        nombre),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              }

              return const SizedBox();
            },
          ),
        ),
      ],
    );
  }
}
 */