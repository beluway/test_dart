import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:test_dart/blocs/bloc_rutinas.dart';
import 'package:test_dart/blocs/estados_rutinas.dart';

class PantallaRutina extends StatefulWidget {
  const PantallaRutina({super.key});

  @override
  State<PantallaRutina> createState() => _PantallaRutinaState();
}

class _PantallaRutinaState extends State<PantallaRutina> {
  DateTime _fechaActual = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Disparar la carga del día actual apenas se construye la pantalla.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarRutina(_fechaActual);
    });
  }

  // ===================== LÓGICA BLoC =====================

  /// Dispara el evento al BLoC para cargar la rutina de una fecha específica.
  void _cargarRutina(DateTime fecha) {
    // Usamos BlocProvider.of<BlocRutinas>(context, listen: false)
    // para obtener el BLoC y añadir el evento sin escuchar cambios en el widget.
    BlocProvider.of<BlocRutinas>(context).add(CargarRutinaPorFecha(fecha: fecha));
  }

  void _actualizarFecha(DateTime nuevaFecha) {
    setState(() {
      _fechaActual = nuevaFecha;
    });
    // Dispara el evento para cargar la rutina de la nueva fecha
    _cargarRutina(nuevaFecha);
  }

  void _irDiaAnterior() {
    _actualizarFecha(_fechaActual.subtract(const Duration(days: 1)));
  }

  void _irDiaSiguiente() {
    _actualizarFecha(_fechaActual.add(const Duration(days: 1)));
  }

  // ===================== UI BLoC =====================

  @override
  Widget build(BuildContext context) {
    // Establecer el locale para que DateFormat funcione correctamente en español
    Intl.defaultLocale = 'es_ES';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Rutina de ejercicios'),
      ),
      body: Column(
        children: [
          // ===== BLOQUE SUPERIOR DE NAVEGACIÓN =====
          _buildNavigationHeader(),

          // ===== CONTENIDO (USANDO BLOCBUILDER) =====
          Expanded(
            // BlocBuilder escucha los cambios en BlocRutinas y reacciona al EstadoRutinas
            child: BlocBuilder<BlocRutinas, EstadoRutinas>(
              builder: (context, state) {
                // 1. ESTADO DE CARGA
                if (state is CargandoRutinas) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 2. ESTADO DE ERROR
                if (state is ErrorRutinas) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        '¡Error! ${state.mensaje ?? 'Ocurrió un error al cargar la rutina.'}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                // 3. ESTADO DE ÉXITO (Contiene la lista de mapas o una lista vacía)
                if (state is ExitoRutinas) {
                  // La lista es List<Map<String, dynamic>>
                  final List<Map<String, dynamic>> rutina = state.ejercicios; 

                  if (rutina.isEmpty) {
                    // Rutina vacía
                    return Center(
                      child: Text(
                        state.mensaje ?? 'No hay rutina programada.',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  // Datos cargados
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rutina del día',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        // Usamos el widget de tarjetas con la lista de mapas
                        _buildRutinaCards(rutina),
                      ],
                    ),
                  );
                }

                // Estado por defecto (Inicial o Inactivo)
                return const Center(child: Text('Presiona una fecha para cargar la rutina.'));
              },
            ),
          ),
        ],
      ),
    );
  }

  // ===================== COMPONENTES Y WIDGETS AUXILIARES =====================

  Widget _buildNavigationHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _navButton(
              icon: Icons.chevron_left,
              onTap: _irDiaAnterior,
            ),
            const SizedBox(width: 12),
            Text(
              DateFormat('EEEE, dd/MM/yyyy', 'es_ES').format(_fechaActual),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 12),
            _navButton(
              icon: Icons.chevron_right,
              onTap: _irDiaSiguiente,
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Calendario mini
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            final fechaSeleccionada = await showDatePicker(
              context: context,
              initialDate: _fechaActual,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
              locale: const Locale('es', 'ES'),
            );

            if (fechaSeleccionada != null) {
              _actualizarFecha(fechaSeleccionada);
            }
          },
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(Icons.calendar_today, size: 18),
          ),
        ),
        const SizedBox(height: 6),
        const Divider(height: 1),
      ],
    );
  }

  Widget _navButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Theme.of(context).colorScheme.primaryContainer,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }

  // Método para construir las tarjetas de ejercicio
  // Recibe la lista de Mapas de la DB
  Widget _buildRutinaCards(List<Map<String, dynamic>> rutina) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rutina.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        // Obtenemos el Mapa con la información del ejercicio
        final Map<String, dynamic> ejercicio = rutina[index]; 

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ACCESO AL NOMBRE (USANDO CLAVE DE MAPA Y CASTEO)
                Text(
                  (ejercicio['nombre_ejercicio'] as String?) ?? 'Ejercicio sin nombre',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const SizedBox(width: 8),
                    _infoChip(
                      icon: Icons.fitness_center,
                      // ACCESO A REPETICIONES
                      label: '${ejercicio['repeticiones'] as int? ?? 0} reps',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // ACCESO A DESCRIPCIÓN
                Text(
                  (ejercicio['descripcion_ejercicio'] as String?) ?? 'Sin descripción',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String label,
  }) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      backgroundColor: Colors.grey.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
