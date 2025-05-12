import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _identificacionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _celularController = TextEditingController();
  final TextEditingController _fechaNacimientoController = TextEditingController();
  final TextEditingController _ciudadController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _fechaNacimientoController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _register(BuildContext context) async {
    if (_identificacionController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _nombreController.text.isEmpty ||
        _apellidoController.text.isEmpty ||
        _celularController.text.isEmpty ||
        _fechaNacimientoController.text.isEmpty ||
        _ciudadController.text.isEmpty ||
        _contrasenaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor complete todos los campos')),
      );
      return;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(_identificacionController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La identificación debe contener solo números')),
      );
      return;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(_celularController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El celular debe contener solo números')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8860/usuarios/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'identificacion': int.parse(_identificacionController.text),
          'email': _emailController.text,
          'nombre': _nombreController.text,
          'apellido': _apellidoController.text,
          'celular': int.parse(_celularController.text),
          'fechaNacimiento': _fechaNacimientoController.text,
          'ciudad': _ciudadController.text,
          'contrasena': _contrasenaController.text,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro exitoso')),
        );
        Navigator.pop(context);
      } else {
        String errorMessage;
        try {
          final errorResponse = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorResponse['message']?.toString() ?? 'Error desconocido';
        } catch (e) {
          errorMessage = utf8.decode(response.bodyBytes); // Para texto plano
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $errorMessage')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      appBar: AppBar(
        title: const Text('Registro', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _identificacionController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Número de Identificación',
                prefixIcon: Icon(Icons.badge, color: Colors.deepPurple),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                prefixIcon: Icon(Icons.person, color: Colors.deepPurple),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _apellidoController,
              decoration: const InputDecoration(
                labelText: 'Apellido',
                prefixIcon: Icon(Icons.person_outline, color: Colors.deepPurple),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(Icons.email, color: Colors.deepPurple),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _celularController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Celular',
                prefixIcon: Icon(Icons.phone, color: Colors.deepPurple),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _fechaNacimientoController,
              decoration: const InputDecoration(
                labelText: 'Fecha de Nacimiento',
                prefixIcon: Icon(Icons.calendar_today, color: Colors.deepPurple),
                border: OutlineInputBorder(),
              ),
              onTap: () => _selectDate(context),
              readOnly: true,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _ciudadController,
              decoration: const InputDecoration(
                labelText: 'Ciudad',
                prefixIcon: Icon(Icons.location_city, color: Colors.deepPurple),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _contrasenaController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: Icon(Icons.lock, color: Colors.deepPurple),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : () => _register(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Registrarse',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
