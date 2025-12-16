import 'package:flutter/material.dart';

class DialogoGestionEjercicio extends StatefulWidget {
  final Map<String, dynamic>? ejercicio; // Null si es nuevo
  final DateTime fecha;
  final VoidCallback onGuardar;

  const DialogoGestionEjercicio({
    required this.fecha, 
    required this.onGuardar, 
    this.ejercicio, 
  });

  @override
  State<DialogoGestionEjercicio> createState() => DialogoGestionEjercicioState();
}

class DialogoGestionEjercicioState extends State<DialogoGestionEjercicio> {
  final _formKey = GlobalKey<FormState>();
  
  // Variables para guardar los valores del formulario
  late String _nombreEjercicio;
  late int _series;
  late int _repeticiones;
  // Podrías necesitar el ID del ejercicio si estás gestionando la tabla 'ejercicios' aparte
  
  @override
  void initState() {
    super.initState();
    final isEditing = widget.ejercicio != null;
    
    // Inicialización con valores existentes o por defecto
    _nombreEjercicio = isEditing ? widget.ejercicio!['nombre'] as String : '';
    _series = isEditing ? widget.ejercicio!['series'] as int : 3;
    _repeticiones = isEditing ? widget.ejercicio!['reps'] as int : 12;
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // La lógica aquí debe manejar dos escenarios:
      // 1. Si es nuevo: Añadir una nueva entrada en rutina_ejercicio.
      // 2. Si es edición: Actualizar la entrada existente en rutina_ejercicio.
      
      // TODO: 1. Obtener el ID de la indicación para la widget.fecha
      // TODO: 2. Buscar/Crear el ejercicio en la tabla 'ejercicios' para obtener su ID
      // TODO: 3. Usar el DaoRutinaEjercicio (a través del Bloc) para INSERTAR o ACTUALIZAR
      
      print('--- Guardando/Actualizando Ejercicio ---');
      print('Fecha: ${widget.fecha.toIso8601String()}');
      print('Ejercicio: $_nombreEjercicio');
      print('Series: $_series, Repeticiones: $_repeticiones');
      
      // Simulación de guardado exitoso y recarga de la lista
      widget.onGuardar();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.ejercicio == null ? 'Añadir Nuevo Ejercicio' : 'Editar Ejercicio'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Nombre del Ejercicio
              TextFormField(
                initialValue: _nombreEjercicio,
                decoration: const InputDecoration(labelText: 'Nombre del Ejercicio'),
                validator: (value) => value == null || value.isEmpty ? 'Ingrese el nombre del ejercicio' : null,
                onSaved: (value) => _nombreEjercicio = value!,
              ),
              
              // 2. Series
              TextFormField(
                initialValue: _series.toString(),
                decoration: const InputDecoration(labelText: 'Series'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final number = int.tryParse(value ?? '');
                  if (number == null || number <= 0) {
                    return 'Debe ser un número válido';
                  }
                  return null;
                },
                onSaved: (value) => _series = int.parse(value!),
              ),
              
              // 3. Repeticiones
              TextFormField(
                initialValue: _repeticiones.toString(),
                decoration: const InputDecoration(labelText: 'Repeticiones'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final number = int.tryParse(value ?? '');
                  if (number == null || number <= 0) {
                    return 'Debe ser un número válido';
                  }
                  return null;
                },
                onSaved: (value) => _repeticiones = int.parse(value!),
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