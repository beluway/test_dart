import 'package:flutter/material.dart';
import 'package:test_dart/pantallas/home_personal_trainer.dart';
import 'pantalla_inicio.dart';
import '../servicio_autenticar.dart'; // AuthService

class LoginTrainerScreen extends StatefulWidget {
  const LoginTrainerScreen({super.key});

  @override
  State<LoginTrainerScreen> createState() => _LoginTrainerScreenState();
}

class _LoginTrainerScreenState extends State<LoginTrainerScreen> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _ocultarPassword = true;

  // Usuario fijo (como indica el obligatorio)
  final String usuarioCorrecto = 'admin';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                const Text(
                  "Bios Training",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 40),

                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.90),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Ingreso Personal Trainer",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 25),

                      TextField(
                        controller: _usuarioController,
                        decoration: InputDecoration(
                          labelText: "Usuario",
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      TextField(
                        controller: _passwordController,
                        obscureText: _ocultarPassword,
                        decoration: InputDecoration(
                          labelText: "Contraseña",
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _ocultarPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _ocultarPassword = !_ocultarPassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        onPressed: () async {
                              final user = _usuarioController.text.trim();
                              final pass = _passwordController.text.trim();

                              if (user != usuarioCorrecto) {
                                _mostrarError("Usuario incorrecto");
                                return;
                              }

                              if (pass.isEmpty) {
                                _mostrarError("Ingrese la contraseña");
                                return;
                              }

                              final esCorrecta = await AuthService.verificarPassword(pass);

                              if (esCorrecta) {

                                // 👇 ESTA ES LA LÍNEA QUE TE FALTA
                                await AuthService.setTrainerLogueado(true);

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const PersonalTrainerHome()),
                                );
                              } else {
                                _mostrarError("Contraseña incorrecta");
                              }
                            },


                        child: const Text(
                          "Ingresar",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PantallaInicio(),
                            ),
                          );
                        },
                        child: const Text("Volver a la pantalla principal"),
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

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
