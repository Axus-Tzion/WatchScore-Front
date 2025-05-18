import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:watchscorefront/screens/login_screen.dart';

class UserListsScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const UserListsScreen({super.key, required this.userData});

  @override
  State<UserListsScreen> createState() => _UserListsScreenState();
}

class _UserListsScreenState extends State<UserListsScreen> {
  List<dynamic> _userLists = [];
  bool _isLoading = true;
  String? _error;
  final _httpClient = http.Client();

  @override
  void initState() {
    super.initState();
    _fetchUserLists();
  }

  Future<void> _fetchUserLists() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Usamos el mismo cliente para mantener las cookies
      final response = await _httpClient.get(
        Uri.parse('https://watchscore-1.onrender.com/listas/mis'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _userLists = jsonDecode(utf8.decode(response.bodyBytes));
          _isLoading = false;
        });
      } else if (response.statusCode == 401) {
        _redirectToLogin();
      } else {
        setState(() {
          _error = 'Error al cargar listas: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error de conexión: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _redirectToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _createNewList(String listName) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('https://watchscore-1.onrender.com/listas/usuario'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nombre': listName}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _fetchUserLists();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lista creada exitosamente')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${response.body}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: ${e.toString()}')),
      );
    }
  }

  void _showCreateListDialog() {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nueva Lista'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              labelText: 'Nombre de la lista',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (textController.text.trim().isNotEmpty) {
                  Navigator.pop(context);
                  _createNewList(textController.text.trim());
                }
              },
              child: const Text('Crear'),
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
        title: const Text('Mis Listas', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _showCreateListDialog,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text(_error!))
              : _userLists.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No tienes listas creadas'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _showCreateListDialog,
                      child: const Text('Crear primera lista'),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _fetchUserLists,
                child: ListView.builder(
                  itemCount: _userLists.length,
                  itemBuilder: (context, index) {
                    final lista = _userLists[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      elevation: 2,
                      child: ListTile(
                        leading: const Icon(
                          Icons.list,
                          color: Colors.deepPurple,
                        ),
                        title: Text(lista['nombre'] ?? 'Lista sin nombre'),
                        subtitle: Text(
                          'Películas: ${lista['peliculas']?.length ?? 0} • Series: ${lista['series']?.length ?? 0}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                    );
                  },
                ),
              ),
    );
  }

  @override
  void dispose() {
    _httpClient.close();
    super.dispose();
  }
}
