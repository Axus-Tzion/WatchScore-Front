import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:watchscorefront/screens/login_screen.dart';
import 'package:watchscorefront/screens/userListsScreen.dart';

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
  bool _showPassword = false;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
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
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _identificacionController.dispose();
    _emailController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _celularController.dispose();
    _ciudadController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> updateData = {
        'identificacion': _identificacionController.text,
        'email': _emailController.text,
        'nombre': _nombreController.text,
        'apellido': _apellidoController.text,
        'celular': _celularController.text,
        'ciudad': _ciudadController.text,
      };

      // Solo agregamos la contraseña si se proporcionó una nueva
      if (_passwordController.text.isNotEmpty) {
        updateData['password'] = _passwordController.text;
      }

      final response = await http.put(
        Uri.parse('https://watchscore-1.onrender.com/usuarios/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _isEditing = false;
          _passwordController.clear();
        });

        // Actualizar datos locales
        widget.userData['email'] = _emailController.text;
        widget.userData['nombre'] = _nombreController.text;
        widget.userData['apellido'] = _apellidoController.text;
        widget.userData['celular'] = _celularController.text;
        widget.userData['ciudad'] = _ciudadController.text;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: ${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
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
              onPressed:
                  () => setState(() {
                    _isEditing = false;
                    _passwordController.clear();
                    _initializeControllers();
                  }),
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
                          _buildProfileHeader(),
                          const SizedBox(height: 20),
                          _buildProfileForm(),
                          if (_isEditing) _buildPasswordField(),
                          if (_isEditing) _buildSaveButton(),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomActions(context),
                ],
              ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.deepPurple[100],
              child: Icon(
                Icons.person,
                size: 60,
                color: Colors.deepPurple[800],
              ),
            ),
            if (_isEditing)
              Container(
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  onPressed: () {},
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          '${widget.userData['nombre'] ?? ''} ${widget.userData['apellido'] ?? ''}',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        Text(
          widget.userData['email'] ?? '',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildProfileForm() {
    return Column(
      children: [
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
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      children: [
        const SizedBox(height: 15),
        TextField(
          controller: _passwordController,
          obscureText: !_showPassword,
          decoration: InputDecoration(
            labelText: 'Nueva Contraseña',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.lock, color: Colors.deepPurple),
            suffixIcon: IconButton(
              icon: Icon(
                _showPassword ? Icons.visibility : Icons.visibility_off,
                color: Colors.deepPurple,
              ),
              onPressed: () {
                setState(() => _showPassword = !_showPassword);
              },
            ),
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Dejar en blanco si no deseas cambiar la contraseña',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: ElevatedButton(
        onPressed: _updateProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          'Guardar Cambios',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => UserListsScreen(userData: widget.userData),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple[100],
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: Icon(Icons.list, color: Colors.deepPurple[800]),
            label: Text(
              'Mis Listas',
              style: TextStyle(color: Colors.deepPurple[800], fontSize: 16),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () => _logout(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[100],
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: Icon(Icons.logout, color: Colors.red[800]),
            label: Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.red[800], fontSize: 16),
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
        labelStyle: TextStyle(
          color: enabled ? Colors.deepPurple : Colors.grey[600],
        ),
      ),
      style: TextStyle(color: enabled ? Colors.black : Colors.grey[600]),
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
