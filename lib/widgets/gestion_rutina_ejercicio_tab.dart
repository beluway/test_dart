
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
                                _anadirEjercicioPorNombre(nombreEjercicio, repeticiones);
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

void _anadirEjercicioPorNombre(String nombre, int repeticiones) {
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
