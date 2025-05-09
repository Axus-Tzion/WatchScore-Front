import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:watchscorefront/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ProfileScreen({super.key, required this.userData});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _identificacionController;
  late TextEditingController _emailController;
  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _celularController;
  late TextEditingController _ciudadController;
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // Inicializamos los controladores con los datos recibidos
    _identificacionController = TextEditingController(
      text: widget.userData['identificacion']?.toString() ?? '',
    );
    _emailController = TextEditingController(
      text: widget.userData['email'] ?? '',
    );
    _nombreController = TextEditingController(
      text: widget.userData['nombre'] ?? '',
    );
    _apellidoController = TextEditingController(
      text: widget.userData['apellido'] ?? '',
    );
    _celularController = TextEditingController(
      text: widget.userData['celular']?.toString() ?? '',
    );
    _ciudadController = TextEditingController(
      text: widget.userData['ciudad'] ?? '',
    );
  }

  @override
  void dispose() {
    // Limpiamos los controladores
    _identificacionController.dispose();
    _emailController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _celularController.dispose();
    _ciudadController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.put(
        Uri.parse('http://127.0.0.1:8860/usuarios/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'identificacion': _identificacionController.text,
          'email': _emailController.text,
          'nombre': _nombreController.text,
          'apellido': _apellidoController.text,
          'celular': _celularController.text,
          'ciudad': _ciudadController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado correctamente')),
        );
        setState(() => _isEditing = false);

        // Actualizamos los datos locales después de una edición exitosa
        widget.userData['identificacion'] = _identificacionController.text;
        widget.userData['email'] = _emailController.text;
        widget.userData['nombre'] = _nombreController.text;
        widget.userData['apellido'] = _apellidoController.text;
        widget.userData['celular'] = _celularController.text;
        widget.userData['ciudad'] = _ciudadController.text;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Estás seguro que deseas cerrar tu sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => setState(() => _isEditing = false),
            ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.deepPurple[100],
                            child: const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildProfileField(
                            label: 'Identificación',
                            controller: _identificacionController,
                            enabled: false,
                          ),
                          const SizedBox(height: 15),
                          _buildProfileField(
                            label: 'Nombre',
                            controller: _nombreController,
                            enabled: _isEditing,
                          ),
                          const SizedBox(height: 15),
                          _buildProfileField(
                            label: 'Apellido',
                            controller: _apellidoController,
                            enabled: _isEditing,
                          ),
                          const SizedBox(height: 15),
                          _buildProfileField(
                            label: 'Email',
                            controller: _emailController,
                            enabled: _isEditing,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 15),
                          _buildProfileField(
                            label: 'Celular',
                            controller: _celularController,
                            enabled: _isEditing,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 15),
                          _buildProfileField(
                            label: 'Ciudad',
                            controller: _ciudadController,
                            enabled: _isEditing,
                          ),
                          const SizedBox(height: 30),
                          if (_isEditing)
                            ElevatedButton(
                              onPressed: _updateProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 15,
                                ),
                              ),
                              child: const Text(
                                'Guardar Cambios',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ElevatedButton.icon(
                      onPressed: () => _logout(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text(
                        'Cerrar Sesión',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: _getIconForField(label),
        filled: !enabled,
        fillColor: Colors.grey[200],
      ),
    );
  }

  Icon _getIconForField(String label) {
    switch (label) {
      case 'Identificación':
        return const Icon(Icons.badge, color: Colors.deepPurple);
      case 'Nombre':
        return const Icon(Icons.person, color: Colors.deepPurple);
      case 'Apellido':
        return const Icon(Icons.person_outline, color: Colors.deepPurple);
      case 'Email':
        return const Icon(Icons.email, color: Colors.deepPurple);
      case 'Celular':
        return const Icon(Icons.phone, color: Colors.deepPurple);
      case 'Ciudad':
        return const Icon(Icons.location_city, color: Colors.deepPurple);
      default:
        return const Icon(Icons.edit, color: Colors.deepPurple);
    }
  }
}
