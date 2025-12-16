import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _clavePassword = 'trainer_password';
  static const String _trainerLogueado = 'trainer_logueado';

  /// Obtener password del trainer (default = admin)
  static Future<String> obtenerPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_clavePassword) ?? 'admin';
  }

  /// Guardar nueva password
  static Future<void> guardarPassword(String nuevaPassword) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_clavePassword, nuevaPassword);
  }

  /// Verificar si la contraseña ingresada coincide
  static Future<bool> verificarPassword(String passwordIngresada) async {
    final actual = await obtenerPassword();
    return passwordIngresada == actual;
  }

  /// Guardar estado de login del trainer
  static Future<void> setTrainerLogueado(bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_trainerLogueado, valor);
  }

  /// Saber si el trainer está logueado ahora mismo
  static Future<bool> estaLogueado() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_trainerLogueado) ?? false;
  }

  /// Cerrar sesión
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_trainerLogueado, false);
  }
}
