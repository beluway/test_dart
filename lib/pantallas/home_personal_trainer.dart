import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_dart/blocs/bloc_rutinas.dart';
import 'package:test_dart/pantallas/pantalla_Cambiar_pass.dart';
import 'package:test_dart/pantallas/pantalla_gestion_indicaciones.dart';
import 'package:test_dart/pantallas/pantalla_inicio.dart';
import 'package:test_dart/pantallas/mantenimiento_ejercicios.dart';
import '../servicio_autenticar.dart';

class PersonalTrainerHome extends StatelessWidget {
  const PersonalTrainerHome({super.key});

  // --- Tarjeta moderna reutilizable ---
  Widget _buildNavigationButton(
      BuildContext context, String title, IconData icon, Widget targetScreen) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => targetScreen),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Theme.of(context).primaryColor),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel del Personal Trainer", style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // ------------------ Drawer (Menú Lateral) ------------------
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: primaryColor),
              child: const Text(
                "Personal Trainer",
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
            ),

            // CAMBIAR CONTRASEÑA
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text("Cambiar contraseña"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PantallaCambiarContrasena()),
                );
              },
            ),

            // CERRAR SESIÓN (LO IMPORTANTE)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Cerrar sesión"),
              onTap: () async {
                Navigator.pop(context);
                await AuthService.logout();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const PantallaInicio()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),

      // ------------------ BODY MODERNO ------------------
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                "Bienvenido al Panel de Personal Trainer",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Tarjetas modernas
            _buildNavigationButton(
              context,
              "Mantenimiento de Ejercicios",
              Icons.fitness_center,
               MantenimientoEjercicios(),
            ),

            _buildNavigationButton(
              context,
              "Gestión de Rutinas y Comidas",
              Icons.schedule,
              const GestionIndicaciones(),
            ),

            const SizedBox(height: 40),
            Center(
              child: Icon(Icons.person_pin, size: 110, color: Colors.grey.shade300),
            )
          ],
        ),
      ),
    );
  }
}
