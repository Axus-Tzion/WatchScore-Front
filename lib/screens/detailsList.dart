import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DetailsListScreen extends StatefulWidget {
  final Map lista;

  const DetailsListScreen({Key? key, required this.lista}) : super(key: key);

  @override
  State<DetailsListScreen> createState() => _DetailsListScreenState();
}

class _DetailsListScreenState extends State<DetailsListScreen> {
  late List<dynamic> _contenido;

  @override
  void initState() {
    super.initState();
    _contenido = [
      ...(widget.lista['series'] ?? []),
      ...(widget.lista['peliculas'] ?? []),
    ];
  }

  Future<void> _eliminarDeLista(dynamic item) async {
    final nombreLista = widget.lista['nombre'];
    final tituloContenido = item['titulo'];

    final url = Uri.parse(
      'https://watchscore-1.onrender.com/listas/eliminar/$nombreLista/peliculas/$tituloContenido',
    );

    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        setState(() {
          _contenido.remove(item);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contenido eliminado de la lista')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar el contenido')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error de conexión')));
    }
  }

  void _verDetalles(dynamic item) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(item['titulo'] ?? 'Sin título'),
            content: const Text('Aquí podrías mostrar los detalles.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lista['nombre'] ?? 'Lista'),
        backgroundColor: Colors.deepPurple,
      ),
      body:
          _contenido.isEmpty
              ? const Center(child: Text('Esta lista no tiene contenido.'))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: _contenido.length,
                  itemBuilder: (context, index) {
                    final item = _contenido[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        title: Text(
                          item['titulo'] ?? 'Sin título',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        leading: const Icon(
                          Icons.movie,
                          color: Colors.deepPurple,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _eliminarDeLista(item),
                        ),
                        onTap: () => _verDetalles(item),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
