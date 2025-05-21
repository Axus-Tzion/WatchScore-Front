import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:watchscorefront/screens/detailsList.dart';

class ListUserScreen extends StatefulWidget {
  final int userId;
  final Map<String, dynamic> userData;

  const ListUserScreen({Key? key, required this.userId, required this.userData})
    : super(key: key);

  @override
  State<ListUserScreen> createState() => _ListUserScreenState();
}

class _ListUserScreenState extends State<ListUserScreen> {
  List<dynamic> _listas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _obtenerListas();
  }

  Future<void> _obtenerListas() async {
    final userId = widget.userId;
    final url = Uri.parse(
      'https://watchscore-1.onrender.com/listas/misListas/$userId',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _listas = json.decode(response.body);
          _cargando = false;
        });
      } else {
        _mostrarError('Error al cargar las listas');
      }
    } catch (e) {
      _mostrarError('Error de conexión al cargar las listas');
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  void _irADetalleLista(Map lista) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailsListScreen(lista: lista)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Listas'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body:
          _cargando
              ? const Center(child: CircularProgressIndicator())
              : _listas.isEmpty
              ? const Center(child: Text('No tienes listas creadas.'))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: _listas.length,
                  itemBuilder: (context, index) {
                    final lista = _listas[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const Icon(
                          Icons.list_alt,
                          color: Colors.deepPurple,
                        ),
                        title: Text(
                          lista['nombre'] ?? 'Lista sin nombre',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 20),
                        onTap: () => _irADetalleLista(lista),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
