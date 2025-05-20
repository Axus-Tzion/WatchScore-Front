import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watchscorefront/screens/login_screen.dart';
import 'package:watchscorefront/screens/userListsScreen.dart';

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

    if (widget.userData != null) {
      _userData = widget.userData!;
    } else {
      _userData = {
        'identificacion': prefs.getInt('userId'),
        'email': prefs.getString('userEmail'),
        'nombre': prefs.getString('userName'),
        'apellido': prefs.getString('userLastName'),
        'celular': prefs.getString('userPhone'),
        'ciudad': prefs.getString('userCity'),
        'fechaNacimiento': prefs.getString('userBirthDate'),
      };
    }

    setState(() => _isLoading = false);
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
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
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.deepPurple[100],
          child: Icon(Icons.person, size: 60, color: Colors.deepPurple[800]),
        ),
        const SizedBox(height: 10),
        Text(
          '${_userData['nombre'] ?? ''} ${_userData['apellido'] ?? ''}',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        Text(
          _userData['email'] ?? '',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildProfileInfo() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información de Perfil',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildInfoItem(
              'Identificación',
              _userData['identificacion']?.toString() ?? '',
            ),
            _buildInfoItem('Nombre', _userData['nombre'] ?? ''),
            _buildInfoItem('Apellido', _userData['apellido'] ?? ''),
            _buildInfoItem('Email', _userData['email'] ?? ''),
            _buildInfoItem('Celular', _userData['celular']?.toString() ?? ''),
            _buildInfoItem('Ciudad', _userData['ciudad'] ?? ''),
            _buildInfoItem(
              'Fecha Nacimiento',
              _userData['fechaNacimiento']?.toString() ?? '',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.grey[100],
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserListsScreen(userData: _userData),
                ),
              );
            },
            child: const Text('Mis Listas'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => _logout(context),
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
