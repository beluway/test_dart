import 'package:flutter/material.dart';

class DialogoGestionComida extends StatefulWidget {
  final Map<String, dynamic>? comida; // Null si es nuevo
  final DateTime fecha;
  final VoidCallback onGuardar;

  const DialogoGestionComida({super.key, this.comida, required this.fecha, required this.onGuardar});

  @override
  State<DialogoGestionComida> createState() => DialogoGestionComidaState();
}

class DialogoGestionComidaState extends State<DialogoGestionComida> {
  final _formKey = GlobalKey<FormState>();
  late String _hora;
  late String _nombre;
  late String _porcion;

  @override
  void initState() {
    super.initState();
    final isEditing = widget.comida != null;
    _hora = isEditing ? widget.comida!['hora'] as String : '';
    _nombre = isEditing ? widget.comida!['nombre'] as String : '';
    _porcion = isEditing ? widget.comida!['porcion'] as String : '';
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // TODO: 1. Llamar al DaoComidas/Bloc para guardar o actualizar
      print('Guardando/Actualizando comida para ${widget.fecha.toIso8601String()}');
      print('Datos: Hora: $_hora, Nombre: $_nombre, Porción: $_porcion');
      
      // Simulación de guardado exitoso
      widget.onGuardar();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.comida == null ? 'Añadir Nueva Comida' : 'Editar Comida'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: _hora,
                decoration: const InputDecoration(labelText: 'Hora (Ej: 08:00)'),
                keyboardType: TextInputType.datetime,
                validator: (value) => value!.isEmpty ? 'Ingrese la hora' : null,
                onSaved: (value) => _hora = value!,
              ),
              TextFormField(
                initialValue: _nombre,
                decoration: const InputDecoration(labelText: 'Nombre del Alimento'),
                validator: (value) => value!.isEmpty ? 'Ingrese el nombre' : null,
                onSaved: (value) => _nombre = value!,
              ),
              TextFormField(
                initialValue: _porcion,
                decoration: const InputDecoration(labelText: 'Porción (Ej: 1 taza)'),
                validator: (value) => value!.isEmpty ? 'Ingrese la porción' : null,
                onSaved: (value) => _porcion = value!,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _guardar,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}