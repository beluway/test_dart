/* 
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_dart/blocs/bloc_rutinas.dart';
import 'package:test_dart/blocs/estados_rutinas.dart';
import 'package:test_dart/blocs/evento_rutinas.dart';
import 'package:test_dart/dominio/ejercicio.dart';
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

  /// 🎯 2. IMPLEMENTACIÓN: Envía el evento al BLoC para AGREGAR.
  void _anadirEjercicio(Ejercicio ejercicio, int repeticiones) {
    // 1. Disparar el evento de AGREGAR, que maneja la creación de Rutina/Indicacion
    BlocProvider.of<BlocRutinas>(context).add(
        AgregarEjercicioARutina(
            fecha: _fechaActual, // La fecha que el usuario está viendo
            idEjercicio: ejercicio.id ?? 0,
            repeticiones: repeticiones,
        )
    );
    
    // 2. Feedback (Opcional)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Añadiendo ${ejercicio.nombre} a la rutina...')),
    );
  }
  
  /// 🎯 3. IMPLEMENTACIÓN: Lógica de EDICIÓN (Placeholder)
  void _editarEjercicio(Ejercicio ejercicio, int repeticiones, Map<String, dynamic> datosOriginales) {
    // ⚠️ Lógica PENDIENTE. Esto requerirá un nuevo evento en el BLoC (e.g., EditarEjercicioDeRutina)
    final int idRutina = (datosOriginales['id_rutina'] as int?)?? 0;

    // Aquí iría el evento de Edición
    /* BlocProvider.of<BlocRutinas>(context).add(
        EditarEjercicioDeRutina(
            idRutina: idRutina, 
            idEjercicio: ejercicio.id, // El ID que se está editando
            nuevasRepeticiones: repeticiones,
            fechaActual: _fechaActual
        )
    );
    */
    
    // Feedback temporal
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pendiente: Editar Rutina ID $idRutina, Repeticiones $repeticiones')),
    );
  }

/*   /// Muestra el diálogo para Añadir/Editar.
  Future<void> _mostrarDialogoEjercicio(Map<String, dynamic>? ejercicioExistente) async {
    // ... (el cuerpo de esta función se mantiene como lo enviaste)
    Ejercicio? _ejercicioSeleccionado;
    TextEditingController _repeticionesController = TextEditingController();
    
    // Si estamos editando un ejercicio existente, pre-cargamos los valores
    if (ejercicioExistente != null) {
        final int idEjercicio = (ejercicioExistente['id_ejercicio'] as int?) ?? 0;
        final String nombreEjercicio = (ejercicioExistente['nombre_ejercicio'] as String?) ?? '';
        final int repeticiones = (ejercicioExistente['repeticiones'] as int?) ?? 0;

        // Intentamos encontrar el objeto Ejercicio real (asumiendo que está disponible)
        _ejercicioSeleccionado = _ejerciciosDisponibles.firstWhere(
            (e) => e.id == idEjercicio, 
            orElse: () => Ejercicio(id: idEjercicio, nombre: nombreEjercicio) 
        );

        _repeticionesController.text = repeticiones.toString();
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
                            // 1. Selector de Ejercicio (DropdownButton)
                            StatefulBuilder(
                                builder: (BuildContext context, StateSetter setStateInterno) {
                                    return DropdownButtonFormField<Ejercicio>(
                                        decoration: const InputDecoration(labelText: 'Ejercicio'),
                                        value: _ejercicioSeleccionado,
                                        items: _ejerciciosDisponibles.map((e) {
                                            return DropdownMenuItem<Ejercicio>(
                                                value: e,
                                                child: Text(e.nombre),
                                            );
                                        }).toList(),
                                        onChanged: (Ejercicio? nuevoEjercicio) {
                                            setStateInterno(() {
                                                _ejercicioSeleccionado = nuevoEjercicio;
                                            });
                                        },
                                    );
                                },
                            ),
                            const SizedBox(height: 20),
                            
                            // 2. Input de Repeticiones
                            TextFormField(
                                controller: _repeticionesController,
                                decoration: const InputDecoration(
                                    labelText: 'Repeticiones',
                                    border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
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
                            // 3. Validar y Procesar la acción
                            final int? repeticiones = int.tryParse(_repeticionesController.text);

                            if (_ejercicioSeleccionado == null || repeticiones == null || repeticiones <= 0) {
                                // Muestra un mensaje de error si la validación falla
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Seleccione un ejercicio y repeticiones válidas.')),
                                );
                                return;
                            }

                            Navigator.of(context).pop(); // Cerrar el diálogo

                            // Lógica para AÑADIR o EDITAR
                            if (ejercicioExistente == null) {
                                // ➡️ AÑADIR (Llamada al método implementado)
                                _anadirEjercicio(_ejercicioSeleccionado!, repeticiones);
                            } else {
                                // ➡️ EDITAR (Llamada al método implementado)
                                _editarEjercicio(_ejercicioSeleccionado!, repeticiones, ejercicioExistente);
                            }
                        },
                        child: Text(ejercicioExistente == null ? 'Añadir' : 'Guardar'),
                    ),
                ],
            );
        },
    );
  } */

 Future<void> _mostrarDialogoEjercicio(Map<String, dynamic>? ejercicioExistente) async {
    // ⚠️ Importante: Usaremos 'nombre' y no 'id' para la lógica del DAO.
    TextEditingController _nombreEjercicioController = TextEditingController();
    TextEditingController _repeticionesController = TextEditingController();
    TextEditingController _descripcionController = TextEditingController();
    
    // Si estamos editando, pre-cargamos los valores
    if (ejercicioExistente != null) {
        final String nombreEjercicio = (ejercicioExistente['nombre_ejercicio'] as String?) ?? '';
        final int repeticiones = (ejercicioExistente['repeticiones'] as int?) ?? 0;

        _nombreEjercicioController.text = nombreEjercicio;
        _repeticionesController.text = repeticiones.toString();
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
                                controller: _nombreEjercicioController,
                                decoration: const InputDecoration(
                                    labelText: 'Nombre del Ejercicio',
                                    border: OutlineInputBorder(),
                                ),
                                // Si estamos editando, no permitimos cambiar el nombre
                                readOnly: ejercicioExistente != null, 
                            ),
                            const SizedBox(height: 20),
                            
                            // 2. Input de Repeticiones
                            TextFormField(
                                controller: _repeticionesController,
                                decoration: const InputDecoration(
                                    labelText: 'Repeticiones',
                                    border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                            ),
                              // 2. Input de descripción
                            TextFormField(
                                controller: _descripcionController,
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
                            final String nombreEjercicio = _nombreEjercicioController.text.trim();
                            final int? repeticiones = int.tryParse(_repeticionesController.text);
                            final String descripcion = _descripcionController.text.trim();

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
                                _editarEjercicioPorNombre(nombreEjercicio, repeticiones, ejercicioExistente);
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

// 📌 Placeholder para editar
void _editarEjercicioPorNombre(String nombre, int repeticiones, Map<String, dynamic> datosOriginales) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pendiente: Lógica de edición para $nombre.')),
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
                    child: ElevatedButton.icon(
                        onPressed: () => _mostrarDialogoEjercicio(null), 
                        icon: const Icon(Icons.add),
                        label: Text(buttonLabel),
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

                                        return Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                            child: Card(
                                                child: ListTile(
                                                    leading: const Icon(Icons.fitness_center),
                                                    title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                                                    subtitle: Text('Repeticiones: $repeticiones'), 
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

      ],
    );
  }
}
 */

import 'package:flutter/material.dart';
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
