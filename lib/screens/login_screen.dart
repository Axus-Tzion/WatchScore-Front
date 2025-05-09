import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async'; // Importación añadida para TimeoutException
import 'dart:convert';
import 'package:watchscorefront/screens/home_screen.dart';
import 'package:watchscorefront/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login(BuildContext context) async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Por favor, completa todos los campos');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http
          .post(
            Uri.parse('http://127.0.0.1:8860/usuarios/LogIn'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': _emailController.text.trim(),
              'contrasena': _passwordController.text.trim(),
            }),
          )
          .timeout(const Duration(seconds: 15));

      _handleLoginResponse(response, context);
    } on TimeoutException catch (e) {
      // Ahora reconocido correctamente
      _showError('Tiempo de espera agotado: ${e.message}');
    } on http.ClientException catch (e) {
      _showError('Error de conexión: ${e.message}');
    } catch (e) {
      _showError('Error inesperado: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleLoginResponse(http.Response response, BuildContext context) {
    switch (response.statusCode) {
      case 200:
        try {
          final userData = jsonDecode(response.body);
          if (userData['email'] == null) {
            throw const FormatException('Respuesta inválida del servidor');
          }
          Navigator.pushReplacementNamed(context, '/home', arguments: userData);
        } on FormatException {
          _showError('Formato de respuesta incorrecto');
        }
        break;
      case 401:
        _showError('Credenciales incorrectas');
        break;
      case 404:
        _showError('Endpoint no encontrado');
        break;
      case 500:
        _showError('Error interno del servidor');
        break;
      default:
        _showError('Error desconocido (${response.statusCode})');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'WatchScore',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(Icons.email, color: Colors.deepPurple),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: Icon(Icons.lock, color: Colors.deepPurple),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : () => _login(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
              ),
              child:
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                        'Iniciar sesión',
                        style: TextStyle(color: Colors.white),
                      ),
            ),
            TextButton(
              onPressed:
                  _isLoading
                      ? null
                      : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      ),
              child: const Text(
                '¿No tienes cuenta? Regístrate',
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
