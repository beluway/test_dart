import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:test_dart/blocs/bloc_rutinas.dart';
import 'package:test_dart/pantallas/home_personal_trainer.dart';
import 'pantallas/pantalla_inicio.dart';
import 'servicio_autenticar.dart';   // 👈 importante
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  

  // Inicializar formato de fechas
  await initializeDateFormatting('es', null);
  Intl.defaultLocale = 'es';

  // Consultar si el personal trainer está logueado actualmente
  final bool logueado = await AuthService.estaLogueado();


  runApp(MiApp(logueado: logueado));
}

class MiApp extends StatelessWidget {
  final bool logueado;

  const MiApp({super.key, required this.logueado});

  @override
  Widget build(BuildContext context) {

    final DateTime fechaInicial = DateTime.now();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => BlocRutinas()..add(CargarRutinaPorFecha(fecha:fechaInicial)),
          )
      ],

      child: MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const [
          Locale('es'),
        ],
      
        title: "Entrenamiento",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
      
        // Si está logueado → ir directo al home del personal
        // Si no lo está → mostrar la pantalla de inicio del cliente
        home: logueado
            ?  PersonalTrainerHome()
            :  PantallaInicio(),
      ),
    );
  }


}
