import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditMovieScreen extends StatefulWidget {
  final Map<String, dynamic> movie;

  const EditMovieScreen({super.key, required this.movie});

  @override
  State<EditMovieScreen> createState() => _EditMovieScreenState();
}

class _EditMovieScreenState extends State<EditMovieScreen> {
  late TextEditingController tituloController;
  late TextEditingController generoController;
  late TextEditingController lanzamientoController;
  late TextEditingController sinopsisController;
  late TextEditingController duracionController;
  late TextEditingController calificacionController;
  late TextEditingController directorController;
  late TextEditingController actoresController;

  @override
  void initState() {
    super.initState();
    final movie = widget.movie;

    tituloController = TextEditingController(text: movie['titulo']);
    generoController = TextEditingController(text: movie['genero']);
    lanzamientoController = TextEditingController(
      text: movie['lanzamiento'].toString(),
    );
    sinopsisController = TextEditingController(text: movie['sinopsis']);
    duracionController = TextEditingController(text: movie['duracion']);
    calificacionController = TextEditingController(
      text: movie['calificacion'].toString(),
    );

    final director = movie['director'];
    directorController = TextEditingController(
      text: director is Map ? director['nombre'] ?? '' : director ?? '',
    );

    final actores = movie['actores'] ?? [];
    actoresController = TextEditingController(
      text: actores
          .map((a) => a is Map ? a['nombre'] : a.toString())
          .join(', '),
    );
  }

  Future<void> _guardarCambios() async {
    final id = widget.movie['id'];
    final url = Uri.parse('http://localhost:8860/peliculas/actualizar/$id');

    final body = {
      'titulo': tituloController.text,
      'genero': generoController.text,
      'lanzamiento': int.tryParse(lanzamientoController.text),
      'sinopsis': sinopsisController.text,
      'duracion': duracionController.text,
      'calificacion': double.tryParse(calificacionController.text),
      'director': directorController.text,
      'actores':
          actoresController.text.split(',').map((e) => e.trim()).toList(),
    };

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        final updatedMovie = jsonDecode(response.body);
        if (mounted) {
          Navigator.pop(context, {
            'actualizado': true,
            'peliculaActualizada': updatedMovie,
          });
        }
      } else {
        _mostrarError('Error al actualizar la película.');
      }
    } catch (e) {
      _mostrarError('Fallo la conexión al servidor.');
    }
  }

  void _mostrarError(String mensaje) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Error'),
            content: Text(mensaje),
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
        title: const Text('Editar Película'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildTextField(tituloController, 'Título'),
            _buildTextField(generoController, 'Género'),
            _buildTextField(lanzamientoController, 'Año de lanzamiento'),
            _buildTextField(sinopsisController, 'Sinopsis'),
            _buildTextField(duracionController, 'Duración'),
            _buildTextField(calificacionController, 'Calificación'),
            _buildTextField(directorController, 'Director'),
            _buildTextField(actoresController, 'Actores (separados por coma)'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _guardarCambios,
              child: const Text('Guardar cambios'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
