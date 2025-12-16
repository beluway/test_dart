import 'package:flutter/material.dart';
import 'package:test_dart/dominio/ejercicio.dart';
import 'package:test_dart/daos/dao_ejercicios.dart';

class MantenimientoEjercicios extends StatefulWidget {
  const MantenimientoEjercicios({super.key});

  @override
  State<MantenimientoEjercicios> createState() => _MantenimientoEjerciciosState();
}

class _MantenimientoEjerciciosState extends State<MantenimientoEjercicios> {
  List<Ejercicio> _ejercicios = [];

  @override
  void initState() {
    super.initState();
    print('InitState ejecutado');
    _cargarEjercicios();
  }

  // ============================
  // CARGAR EJERCICIOS DESDE SQLITE
  // ============================
  Future<void> _cargarEjercicios() async {
    final lista = await DaoEjercicios().listarEjercicios();

    if (!mounted) return; // 🔥 SOLUCIÓN

    setState(() {
      _ejercicios = lista;
    });
  }

  // ============================
  // FORMULARIO CREAR / EDITAR
  // ============================
  void _mostrarFormulario(BuildContext context, {Ejercicio? ejercicio}) {
    final esEdicion = ejercicio != null;

    final nombreCtrl = TextEditingController(text: ejercicio?.nombre ?? '');
    final descripcionCtrl = TextEditingController(text: ejercicio?.descripcion ?? '');
    /* final fotoCtrl = TextEditingController(text: ejercicio?.fotografia ?? ''); */

    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    esEdicion ? "Editar Ejercicio" : "Nuevo Ejercicio",
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                  const SizedBox(height: 20),

                  // Nombre
                  TextFormField(
                    controller: nombreCtrl,
                    decoration: const InputDecoration(
                      labelText: "Nombre",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.fitness_center),
                    ),
                    validator: (v) => v!.isEmpty ? "Campo requerido" : null,
                  ),
                  const SizedBox(height: 15),

                  // Descripción
                  TextFormField(
                    controller: descripcionCtrl,
                    decoration: const InputDecoration(
                      labelText: "Descripción",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 15),

                  /* // Foto
                  TextFormField(
                    controller: fotoCtrl,
                    decoration: const InputDecoration(
                      labelText: "Ruta de imagen (opcional)",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.image),
                    ),
                  ),

                  const SizedBox(height: 25), */

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(esEdicion ? Icons.save : Icons.add, color: Colors.white),
                      label: Text(
                        esEdicion ? "Guardar Cambios" : "Crear Ejercicio",
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;

                        final nuevo = Ejercicio(
                          id: ejercicio?.id,
                          nombre: nombreCtrl.text,
                          descripcion: descripcionCtrl.text,
                          /* fotografia: fotoCtrl.text.isEmpty ? null : fotoCtrl.text, */
                        );

                        if (esEdicion) {
                          await DaoEjercicios().actualizarEjercicio(nuevo);
                        } else {
                          await DaoEjercicios().insertarEjercicio(nuevo);
                        }

                        if (!mounted) return; // 🔥 SOLUCIÓN
                        Navigator.pop(context);
                        _cargarEjercicios();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================
  // CONFIRMAR ELIMINAR
  // ============================
  void _confirmarEliminar(Ejercicio ejercicio) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmar eliminación"),
        content: Text("¿Eliminar '${ejercicio.nombre}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              await DaoEjercicios().eliminarEjercicio(ejercicio.id!);

              if (!mounted) return; // 🔥 SOLUCIÓN

              Navigator.pop(context);
              _cargarEjercicios();
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ============================
  // UI PRINCIPAL
  // ============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CRUD de Ejercicios", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
      ),

      body: _ejercicios.isEmpty
          ? const Center(
              child: Text("No hay ejercicios cargados."),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: _ejercicios.length,
              itemBuilder: (context, index) {
                final ej = _ejercicios[index];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      ej.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(ej.descripcion ?? ""),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _mostrarFormulario(context, ejercicio: ej),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmarEliminar(ej),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarFormulario(context),
        label: const Text("Agregar"),
        icon: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Colors.black,
      ),
    );
  }
}
