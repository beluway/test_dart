
import 'package:flutter/material.dart';
import 'package:test_dart/blocs/bloc_comidas.dart';
import 'package:test_dart/widgets/calendar.dart';
import 'package:test_dart/widgets/dialogo_gestion_comida.dart';



class GestionComidasTab extends StatefulWidget {
  const GestionComidasTab();

  @override
  State<GestionComidasTab> createState() => _GestionComidasTabState();
}

class _GestionComidasTabState extends State<GestionComidasTab> {
  DateTime _fechaActual = DateTime.now();
  // Future para cargar la lista de comidas para la fecha seleccionada
  late Future<List<dynamic>> _comidasFuture;
  
  // Asume que tienes un BlocComidas o RutinaService
   final BlocComidas _blocComidas = BlocComidas(); 

  @override
  void initState() {
    super.initState();
    _comidasFuture = _cargarComidas(_fechaActual);
  }

  // Simulación de carga (reemplazar con lógica real del Bloc/DAO)
  Future<List<dynamic>> _cargarComidas(DateTime fecha) async {

    final comidas = await _blocComidas.obtenerIndicacionComidaPorFecha(fecha);

    await Future.delayed(const Duration(milliseconds: 300));
    
    return comidas;
  }

  void _actualizarFecha(DateTime nuevaFecha) {
    setState(() {
      _fechaActual = nuevaFecha;
      _comidasFuture = _cargarComidas(nuevaFecha);
    });
  }

  // Función para mostrar el diálogo de edición/creación
  void _mostrarDialogoComida([Map<String, dynamic>? comida]) {
    // Implementación detallada abajo.
    showDialog(
      context: context,
      builder: (context) => DialogoGestionComida(
        comida: comida,
        fecha: _fechaActual,
        onGuardar: () {
          // Después de guardar, recargar la lista
          setState(() {
            _comidasFuture = _cargarComidas(_fechaActual);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Selector de fecha
        SelectorFecha(onDateSelected: _actualizarFecha),
        const Divider(),
        
        // Botón para añadir (si la rutina está vacía)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            onPressed: () => _mostrarDialogoComida(),
            icon: const Icon(Icons.add),
            label: const Text('Añadir Comida'),
          ),
        ),

        // FutureBuilder para mostrar la lista
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: _comidasFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No hay comidas programadas para este día.'));
              }

              final comidas = snapshot.data!;
              return ListView.builder(
                itemCount: comidas.length,
                itemBuilder: (context, index) {
                  final comida = comidas[index];
                  // El diseño de cada ítem de la lista se asemeja a tu wireframe.
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Card(
                      child: ListTile(
                        leading: Text(comida['hora'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        title: Text('${comida['nombre']} [${comida['porcion']}]'),
                        subtitle: Text(comida['descripcion'] as String),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Ícono de Lápiz (Editar)
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () => _mostrarDialogoComida(comida),
                            ),
                            // Ícono de Basura (Eliminar)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                              onPressed: () {
                                // TODO: Implementar lógica de eliminación
                                print('Eliminar comida: ${comida['nombre']}');
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}