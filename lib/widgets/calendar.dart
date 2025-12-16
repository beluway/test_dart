/* import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SelectorFecha extends StatefulWidget {
  const SelectorFecha({super.key});

  @override
  _SelectorFechaState createState() => _SelectorFechaState();
}

class _SelectorFechaState extends State<SelectorFecha> {
  DateTime? fechaSeleccionada;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Seleccionar fecha")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Texto que muestra la fecha elegida
            Text(
              fechaSeleccionada == null
                  ? "No se seleccionó una fecha"
                  : DateFormat("dd/MM/yyyy").format(fechaSeleccionada!),
              style: TextStyle(fontSize: 22),
            ),
            SizedBox(height: 20),

            // Botón que abre el calendario
            ElevatedButton(
              onPressed: () async {
                DateTime? fecha = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  locale: const Locale('es', 'ES'), // Calendario en español
                );

                if (fecha != null) {
                  setState(() {
                    fechaSeleccionada = fecha;
                  });
                }
              },
              child: Text("Seleccionar fecha"),
            ),
          ],
        ),
      ),
    );
  }
} */

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Definimos un nuevo constructor que acepta un parámetro 'onDateSelected'
class SelectorFecha extends StatefulWidget {
  final ValueSetter<DateTime> onDateSelected;

  const SelectorFecha({
    super.key,
    required this.onDateSelected, // Este es el callback
  });

  @override
  _SelectorFechaState createState() => _SelectorFechaState();
}

class _SelectorFechaState extends State<SelectorFecha> {
  // Inicializamos con la fecha actual como valor por defecto.
  DateTime fechaSeleccionada = DateTime.now();

  // Llamada al método de ciclo de vida para inicializar con la fecha actual
  @override
  void initState() {
    super.initState();
    // Llamar al callback inmediatamente para que la PantallaRutina sepa la fecha inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onDateSelected(fechaSeleccionada);
    });
  }

  // Función para mostrar el selector de fecha
  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: fechaSeleccionada,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'ES'), // Calendario en español
    );

    if (fecha != null && fecha != fechaSeleccionada) {
      setState(() {
        fechaSeleccionada = fecha;
      });
      // AQUI: Llamamos al callback para informar al widget padre (PantallaRutina)
      widget.onDateSelected(fecha); 
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ya no necesitamos el Scaffold aquí, solo los elementos del selector.
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Texto que muestra la fecha elegida
          Text(
            DateFormat("EEEE, dd/MM/yyyy", 'es_ES').format(fechaSeleccionada),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          
          // Botón que abre el calendario
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _seleccionarFecha(context),
            tooltip: 'Seleccionar fecha',
          ),
        ],
      ),
    );
  }
}