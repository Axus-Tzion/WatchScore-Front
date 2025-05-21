import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watchscorefront/screens/login_screen.dart';
import 'package:watchscorefront/screens/userListsScreen.dart';

// Asegúrate de que esta ruta sea correcta si existe
// import 'package:watchscorefront/screens/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const ProfileScreen({super.key, this.userData});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> _userData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    // Debugging: Imprime todas las claves y valores guardados en SharedPreferences
    print('--- SharedPreferences Content in ProfileScreen ---');
    prefs.getKeys().forEach((key) {
      print('$key: ${prefs.get(key)} (Type: ${prefs.get(key)?.runtimeType})');
    });
    print('----------------------------------------------------');

    // Prioriza los datos pasados al constructor si existen
    if (widget.userData != null && widget.userData!.isNotEmpty) {
      setState(() {
        _userData = widget.userData!;
        _isLoading = false;
        print('Datos cargados desde widget.userData: $_userData');
      });
      return; // Salir, ya tenemos los datos
    }

    // Si no hay datos en el widget, intenta cargarlos desde SharedPreferences
    final String? userIdentificacionString = prefs.getString(
      'userIdentificacion',
    );
    final String? userEmail = prefs.getString('userEmail');
    final String? userName = prefs.getString('userName');
    final String? userLastName = prefs.getString('userLastName');
    final String? userPhone = prefs.getString('userPhone');
    final String? userCity = prefs.getString('userCity');
    final String? userBirthDate = prefs.getString('userBirthDate');

    setState(() {
      _userData = {
        'identificacion':
            userIdentificacionString != null
                ? int.tryParse(userIdentificacionString)
                : null,
        'email': userEmail,
        'nombre': userName,
        'apellido': userLastName,
        'celular': userPhone,
        'ciudad': userCity,
        'fechaNacimiento': userBirthDate,
      };
      _isLoading = false;
      print(
        'Datos cargados desde SharedPreferences en ProfileScreen: $_userData',
      );
    });

    if (_userData['email'] == null) {
      print(
        'Advertencia: Email de usuario no encontrado en SharedPreferences. Los datos pueden estar incompletos o no guardados.',
      );
    }
  }

  Future<void> _logout(BuildContext context) async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cerrar sesión'),
            content: const Text(
              '¿Estás seguro de que deseas cerrar tu sesión?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs
                      .clear(); // Limpia todos los datos de SharedPreferences
                  // O si prefieres ser más específico:
                  // await prefs.remove('isLoggedIn');
                  // await prefs.remove('userIdentificacion');
                  // ... remueve cada clave de usuario

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                child: const Text(
                  'Cerrar sesión',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mi Perfil', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.deepPurple,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              // Navegar a pantalla de edición
              // Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen(userData: _userData)));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 20),
                  _buildProfileInfo(),
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
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.deepPurple[100],
                border: Border.all(color: Colors.deepPurple, width: 2),
              ),
              child: Icon(
                Icons.person,
                size: 60,
                color: Colors.deepPurple[800],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '${_userData['nombre']?.toString() ?? ''} ${_userData['apellido']?.toString() ?? ''}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _userData['email']?.toString() ?? '',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        if (_userData['ciudad'] != null &&
            (_userData['ciudad'] as String).isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                _userData['ciudad']?.toString() ?? '',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildProfileInfo() {
    final infoItems = [
      _buildInfoTile(
        icon: Icons.assignment_ind,
        title: 'Identificación',
        value: _userData['identificacion']?.toString() ?? 'No especificada',
      ),
      _buildInfoTile(
        icon: Icons.person,
        title: 'Nombre completo',
        value:
            '${_userData['nombre']?.toString() ?? ''} ${_userData['apellido']?.toString() ?? ''}',
      ),
      _buildInfoTile(
        icon: Icons.email,
        title: 'Correo electrónico',
        value: _userData['email']?.toString() ?? 'No especificado',
      ),
      if (_userData['celular'] != null &&
          (_userData['celular'] as String).isNotEmpty)
        _buildInfoTile(
          icon: Icons.phone,
          title: 'Teléfono',
          value: _userData['celular']?.toString() ?? '',
        ),
      if (_userData['fechaNacimiento'] != null &&
          (_userData['fechaNacimiento'] as String).isNotEmpty)
        _buildInfoTile(
          icon: Icons.cake,
          title: 'Fecha de nacimiento',
          value: _userData['fechaNacimiento']?.toString() ?? '',
        ),
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.deepPurple[800]),
                  const SizedBox(width: 8),
                  Text(
                    'Información personal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[800],
                    ),
                  ),
                ],
              ),
            ),
            if (infoItems.isNotEmpty) ...infoItems,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.list),
              label: const Text('Mis listas'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserListsScreen(userData: _userData),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesión'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => _logout(context),
            ),
          ),
        ],
      ),
    );
  }
}
