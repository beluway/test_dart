import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_dart/blocs/bloc_rutinas.dart';
import 'package:test_dart/widgets/gestion_comidas_tab.dart';
import 'package:test_dart/widgets/gestion_rutina_ejercicio_tab.dart';
// Asegúrate de importar tu SelectorFecha
// import 'package:tu_proyecto/widgets/selector_fecha.dart'; 
// Asegúrate de importar tus modelos y DAOs
// import 'package:tu_proyecto/dominio/dominio.dart'; 

class GestionIndicaciones extends StatelessWidget {
  const GestionIndicaciones({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos DefaultTabController para manejar las pestañas
    return DefaultTabController(
      length: 2, // Dos pestañas: Rutinas y Comidas
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Gestión de Indicaciones',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white, // Color del título/iconos del AppBar
          // Definición de las pestañas
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Gestión Comidas'), // Coincide con tu diseño
              Tab(text: 'Gestión Rutina Ejercicio'), // Coincide con tu diseño
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Pestaña 1: Gestión de Comidas
            const GestionComidasTab(), 
            
            // Pestaña 2: Gestión de Rutina de Ejercicios
            const GestionRutinaEjercicioTab(), 
          ],
        ),
      ),
    );
  }
}