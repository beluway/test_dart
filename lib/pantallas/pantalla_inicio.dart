import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test_dart/pantallas/pantalla_login.dart';
import 'pantalla_rutina.dart';
import 'pantalla_comidas.dart';

class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key});

  @override
  Widget build(BuildContext context) {

    // FECHA DE HOY FORMATEADA EN ESPAÑOL
    final DateTime hoy = DateTime.now();
    final String fechaFormateada =
        DateFormat("EEEE d 'de' MMMM", 'es').format(hoy);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bios Training"),
        centerTitle: true,

        // Menú a la izquierda
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),

      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                "Ingrese como Personal Trainer para ver más opciones",
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text("Ingresar"),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginTrainerScreen(),
                    ),
                  );
              },
            ),
          ],
        ),
      ),
      

      // CUERPO PRINCIPAL
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            const Text(
              "¿Qué desea ver hoy?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 15),

            // FECHA FORMATEADA
            Center(
              child: Text(
                fechaFormateada,
                style: const TextStyle(
                  fontSize: 17,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // BOTON RUTINA
            SizedBox(
              height: 120,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PantallaRutina(),
                    ),
                  );
                },
                child: const Text(
                  "Ver rutina del día",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // BOTON COMIDAS
            SizedBox(
              height: 120,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PantallaComidas(),
                    ),
                  );
                },
                child: const Text(
                  "Ver comidas del día",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
