import 'package:flutter/material.dart';

class PantallaComidas extends StatelessWidget {
  const PantallaComidas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Comidas del día")),
      body: const Center(
        child: Text(
          "Aquí irán las comidas del día",
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
