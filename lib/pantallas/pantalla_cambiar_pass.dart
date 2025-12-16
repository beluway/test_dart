import 'package:flutter/material.dart';
import '../servicio_autenticar.dart';

class PantallaCambiarContrasena extends StatefulWidget {
  const PantallaCambiarContrasena({super.key});

  @override
  State<PantallaCambiarContrasena> createState() => _PantallaCambiarContrasenaState();
}

class _PantallaCambiarContrasenaState extends State<PantallaCambiarContrasena> {
  final TextEditingController _actualController = TextEditingController();
  final TextEditingController _nuevaController = TextEditingController();
  final TextEditingController _repetirController = TextEditingController();

  bool _verActual = false;
  bool _verNueva = false;
  bool _verRepetir = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fondo general elegante
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/img/fondo.jpg"),
            fit: BoxFit.cover,
          ),
        ),

        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),

            child: Column(
              children: [

                const Text(
                  "Cambiar contraseña",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 40),

                // TARJETA CENTRAL
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      // CONTRASEÑA ACTUAL
                      _inputPassword(
                        label: "Contraseña actual",
                        controller: _actualController,
                        visible: _verActual,
                        onToggle: () {
                          setState(() => _verActual = !_verActual);
                        },
                      ),

                      const SizedBox(height: 25),

                      // NUEVA CONTRASEÑA
                      _inputPassword(
                        label: "Nueva contraseña",
                        controller: _nuevaController,
                        visible: _verNueva,
                        onToggle: () {
                          setState(() => _verNueva = !_verNueva);
                        },
                      ),

                      const SizedBox(height: 25),

                      // REPETIR CONTRASEÑA
                      _inputPassword(
                        label: "Repetir nueva contraseña",
                        controller: _repetirController,
                        visible: _verRepetir,
                        onToggle: () {
                          setState(() => _verRepetir = !_verRepetir);
                        },
                      ),

                      const SizedBox(height: 35),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _guardar,
                        child: const Text(
                          "Guardar cambios",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputPassword({
    required String label,
    required TextEditingController controller,
    required bool visible,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: !visible,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(visible ? Icons.visibility : Icons.visibility_off),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    final actual = _actualController.text.trim();
    final nueva = _nuevaController.text.trim();
    final repetir = _repetirController.text.trim();

    if (actual.isEmpty || nueva.isEmpty || repetir.isEmpty) {
      _msg("Complete todos los campos", Colors.red);
      return;
    }

    final esValida = await AuthService.verificarPassword(actual);
    if (!esValida) {
      _msg("La contraseña actual es incorrecta", Colors.red);
      return;
    }

    if (nueva != repetir) {
      _msg("Las nuevas contraseñas no coinciden", Colors.red);
      return;
    }

    await AuthService.guardarPassword(nueva);
    await AuthService.setTrainerLogueado(true);

    _msg("Contraseña actualizada correctamente", Colors.green);

    Navigator.pop(context);
  }

  void _msg(String texto, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
