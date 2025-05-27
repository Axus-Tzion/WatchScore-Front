import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watchscorefront/screens/register_screen.dart';
import 'package:watchscorefront/screens/home_screen.dart';
// Importa ProfileScreen si la estás usando directamente desde HomeScreen
// Aunque lo pasas a HomeScreen, es posible que HomeScreen a su vez pase los datos a ProfileScreen
import 'package:watchscorefront/screens/profile_screen.dart'; // ¡Asegúrate de que esta ruta sea correcta!

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();

  Future<void> _login(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://watchscore-1.onrender.com/usuarios/LogIn'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'contrasena': _passwordController.text,
        }),
      );

      final responseBody = jsonDecode(response.body);

      // Imprime la respuesta completa del backend para depurar
      print('Respuesta del backend en Login: $responseBody');

      if (response.statusCode == 200) {
        // Guardar datos de sesión y obtener userData
        // Pasamos responseBody directamente, que es el JSON del usuario
        final userData = await _saveSessionData(responseBody);

        // Navegar a HomeScreen, que probablemente contendrá la ProfileScreen
        // Es crucial que HomeScreen sepa cómo manejar estos datos y pasarlos a ProfileScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(userData: userData)),
        );
      } else {
        _handleLoginError(response.statusCode, responseBody);
      }
    } on http.ClientException catch (e) {
      _showErrorSnackBar('Error de conexión: ${e.message}');
    } on FormatException catch (_) {
      _showErrorSnackBar('Error al procesar la respuesta del servidor');
    } catch (e) {
      _showErrorSnackBar('Ocurrió un error inesperado: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<Map<String, dynamic>> _saveSessionData(
    Map<String, dynamic>
    responseBody, // Renombrado a responseBody para mayor claridad
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // Las claves aquí deben coincidir con los campos de tu entidad Usuario en el backend
    // y cómo se serializan en el JSON de respuesta.
    // Asumiendo que el backend devuelve las claves como en la entidad:
    // identificacion, email, nombre, apellido, celular, ciudad, fechaNacimiento

    // **CORRECCIÓN CLAVE AQUÍ:**
    // responseBody['identificacion'] es la clave de tu entidad, no response['idUsuario']
    await prefs.setString(
      'userIdentificacion',
      responseBody['identificacion']?.toString() ?? '',
    );
    await prefs.setString('userEmail', responseBody['email']?.toString() ?? '');
    await prefs.setString('userName', responseBody['nombre']?.toString() ?? '');
    await prefs.setString(
      'userLastName',
      responseBody['apellido']?.toString() ?? '',
    );
    // responseBody['celular'] es la clave de tu entidad, no response['telefono']
    await prefs.setString(
      'userPhone',
      responseBody['celular']?.toString() ?? '',
    ); // Guarda como String
    await prefs.setString('userCity', responseBody['ciudad']?.toString() ?? '');
    await prefs.setString(
      'userBirthDate',
      responseBody['fechaNacimiento']?.toString() ?? '',
    ); // Fecha viene como String (YYYY-MM-DD)
    // Si tu backend devuelve un token, asegúrate de que la clave sea la correcta, por ejemplo 'token'
    // await prefs.setString('authToken', responseBody['token']?.toString() ?? ''); // Si hay token en la respuesta

    await prefs.setBool('isLoggedIn', true); // Marca al usuario como logueado

    // Imprime lo que se ha guardado en SharedPreferences para verificar
    print('--- SharedPreferences content after login ---');
    prefs.getKeys().forEach((key) {
      print('$key: ${prefs.get(key)} (Type: ${prefs.get(key)?.runtimeType})');
    });
    print('---------------------------------------------');

    // Retorna un mapa con los datos del usuario para pasarlos a la siguiente pantalla
    // Esto es lo que se pasará a HomeScreen, y luego potencialmente a ProfileScreen
    return {
      'identificacion': responseBody['identificacion'],
      'email': responseBody['email'],
      'nombre': responseBody['nombre'],
      'apellido': responseBody['apellido'],
      'celular':
          responseBody['celular']
              ?.toString(), // Asegúrate de que HomeScreen reciba String
      'ciudad': responseBody['ciudad'],
      'fechaNacimiento': responseBody['fechaNacimiento'],
      // 'token': responseBody['token'], // Si hay token
    };
  }

  void _handleLoginError(int statusCode, Map<String, dynamic> response) {
    String errorMessage =
        response['message']?.toString() ??
        'Error desconocido (Código: $statusCode)';

    _showErrorSnackBar(errorMessage);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Image.asset(
                  'assets/images/WatchScoreLogo.png',
                  height: 120,
                  width: 140,
                ),
                const SizedBox(height: 30),
                const Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: const Icon(
                      Icons.email,
                      color: Colors.deepPurple,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu correo electrónico';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Ingresa un correo electrónico válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: Colors.deepPurple,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.deepPurple,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu contraseña';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implementar recuperación de contraseña
                    },
                    child: const Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(color: Colors.deepPurple),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _login(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              'Iniciar sesión',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿No tienes cuenta? '),
                    TextButton(
                      onPressed: _isLoading ? null : _navigateToRegister,
                      child: const Text(
                        'Regístrate',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
