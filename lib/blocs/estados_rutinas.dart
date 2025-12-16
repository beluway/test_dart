import 'package:flutter/foundation.dart';

@immutable
abstract class EstadoRutinas {

  final List<Map<String,Object?>> _ejercicios;
  final String? _mensaje;

  List<Map<String,Object?>> get ejercicios => _ejercicios;
  String? get mensaje => _mensaje;

  const EstadoRutinas(this._ejercicios, [this._mensaje]);

}

//clase para cargar las rutinas
class CargandoRutinas extends EstadoRutinas {
  const CargandoRutinas() : super(const[]);
}

//clase para rutinas cargadas exitosamente
class ExitoRutinas extends EstadoRutinas{
  const ExitoRutinas(super._ejercicios, [super._mensaje]);
}

//clase para error al cargar las rutinas
class ErrorRutinas extends EstadoRutinas{
  const ErrorRutinas(super._ejercicios, [super._mensaje]);
}

// Y un Estado de Éxito/Error para esta operación:
class OperacionExitosa extends EstadoRutinas {
    final String mensaje2;
    const OperacionExitosa(this.mensaje2) : super(const[]);
}

class ErrorListarRutinas extends ErrorRutinas{
  ErrorListarRutinas() : super([], 'Error al listar las rutinas');
}



