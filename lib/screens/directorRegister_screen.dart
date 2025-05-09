import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

class DirectorRegister extends StatefulWidget {
  const DirectorRegister({super.key});

  @override
  State<DirectorRegister> createState() => _DirectorRegisterState();
}

class _DirectorRegisterState extends State<DirectorRegister> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _nacionalidadController = TextEditingController();
  final TextEditingController _fechaNacimientoController =
      TextEditingController();

  String? _generoSeleccionado;
  bool _isLoading = false;

  Future<void> _registrarDirector() async {
    setState(() => _isLoading = true);
    final url = Uri.parse('http://127.0.0.1:8860/director/');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': _nombreController.text,
          'nacionalidad': _nacionalidadController.text,
          'fechaNacimiento': _fechaNacimientoController.text,
          'genero': _generoSeleccionado,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Director registrado exitosamente')),
        );
        _formKey.currentState?.reset();
        _nombreController.clear();
        _nacionalidadController.clear();
        _fechaNacimientoController.clear();
        setState(() => _generoSeleccionado = null);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar director: ${response.body}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error de red: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _seleccionarFechaNacimiento(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1980),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _fechaNacimientoController.text = DateFormat(
          'yyyy-MM-dd',
        ).format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Director'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Campo requerido'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nacionalidadController,
                decoration: const InputDecoration(
                  labelText: 'Nacionalidad',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Campo requerido'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fechaNacimientoController,
                readOnly: true,
                onTap: () => _seleccionarFechaNacimiento(context),
                decoration: const InputDecoration(
                  labelText: 'Fecha de Nacimiento',
                  suffixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Campo requerido'
                            : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _generoSeleccionado,
                decoration: const InputDecoration(
                  labelText: 'Género',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Masculino',
                    child: Text('Masculino'),
                  ),
                  DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
                ],
                onChanged:
                    (value) => setState(() => _generoSeleccionado = value),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Selecciona un género'
                            : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed:
                    _isLoading
                        ? null
                        : () {
                          if (_formKey.currentState!.validate()) {
                            _registrarDirector();
                          }
                        },
                icon:
                    _isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Icon(Icons.save),
                label: Text(
                  _isLoading ? 'Registrando...' : 'Registrar Director',
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
