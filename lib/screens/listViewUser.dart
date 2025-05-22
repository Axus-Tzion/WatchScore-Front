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

  Future<void> _eliminarLista(String listaNombre) async {
    final url = Uri.parse(
      'https://watchscore-1.onrender.com/listas/eliminar/$listaNombre',
    );

    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        setState(() {
          _listas.removeWhere((lista) => lista['nombre'] == listaNombre);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lista eliminada exitosamente')),
        );
      } else {
        _mostrarError('Error al eliminar la lista');
      }
    } catch (e) {
      _mostrarError('Error de conexión al eliminar la lista');
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  void _confirmarEliminacion(String listaNombre) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar lista'),
            content: const Text(
              '¿Estás seguro de que quieres eliminar esta lista?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _eliminarLista(listaNombre);
                },
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed:
                                  () => _confirmarEliminacion(lista['nombre']),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 20),
                          ],
                        ),
                        onTap: () => _irADetalleLista(lista),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
