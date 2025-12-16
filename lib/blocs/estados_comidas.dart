import 'package:flutter/material.dart';
import 'package:test_dart/dominio/dominios.dart';

@immutable
abstract class EstadoComidas {

    final List<Comida> _comidas;
    final String? _mensaje;

  List<Comida> get comidas => _comidas;
    String? get mensaje => _mensaje;

//el mensaje es opcional 
    const EstadoComidas(this._comidas, [this._mensaje]);

}

//clase para cargar las comidas
class CargandoComidas extends EstadoComidas {
  CargandoComidas() : super([]);
}

//clase para comidas cargadas exitosamente
class ExitoComidas extends EstadoComidas{
  const ExitoComidas(super._comidas, [super._mensaje]);
}

//clase para error al cargar las comidas
class ErrorComidas extends EstadoComidas{
  const ErrorComidas(super._comidas, [super._mensaje]);
}

class ErrorListarComidas extends ErrorComidas{
  ErrorListarComidas() : super([], 'Error al listar las comidas');
}

