import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditMovieScreen extends StatefulWidget {
  final Map<String, dynamic> movie;

  const EditMovieScreen({Key? key, required this.movie}) : super(key: key);

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

  List<String> _actoresDisponibles = [];
  List<String> _directoresDisponibles = [];

  @override
  void initState() {
    super.initState();
    final movie = widget.movie;

    tituloController = TextEditingController(text: movie['titulo']);
    generoController = TextEditingController(text: movie['genero']);
    lanzamientoController = TextEditingController(
      text: movie['lanzamiento'].toString(),
    );
    sinopsisController = TextEditingController(text: movie['sipnosis']);
    duracionController = TextEditingController(text: movie['duracion']);
    calificacionController = TextEditingController(
      text: movie['calificacion'].toString(),
    );

    final director = movie['director'];
    directorController = TextEditingController(
      text: director is Map ? director['nombre'] ?? '' : director ?? '',
    );

    final actores = movie['actores'] as List;
    actoresController = TextEditingController(
      text: actores
          .map((a) {
            return a is Map ? a['nombre'] ?? '' : a.toString();
          })
          .join(', '),
    );

    _cargarListas();
  }

  Future<void> _cargarListas() async {
    try {
      final actoresResponse = await http.get(
        Uri.parse('https://watchscore-1.onrender.com/actores/'),
      );
      final directoresResponse = await http.get(
        Uri.parse('https://watchscore-1.onrender.com/director/'),
      );

      if (actoresResponse.statusCode == 200 &&
          directoresResponse.statusCode == 200) {
        final actoresJson = jsonDecode(actoresResponse.body) as List;
        final directoresJson = jsonDecode(directoresResponse.body) as List;

        setState(() {
          _actoresDisponibles =
              actoresJson.map((e) => e['nombre'].toString()).toList();
          _directoresDisponibles =
              directoresJson.map((e) => e['nombre'].toString()).toList();
        });
      }
    } catch (e) {
      print('Error al cargar listas: $e');
    }
  }

  Future<void> _guardarCambios() async {
    final id = widget.movie['id'];
    final url = Uri.parse('http://127.0.0.1:8860/peliculas/actualizar/$id');

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'titulo': tituloController.text,
        'genero': generoController.text,
        'lanzamiento': int.tryParse(lanzamientoController.text),
        'sipnosis': sinopsisController.text,
        'duracion': duracionController.text,
        'calificacion': double.tryParse(calificacionController.text),
        'director': directorController.text,
        'actores':
            actoresController.text.split(',').map((e) => e.trim()).toList(),
      }),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context, _guardarCambios);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar los cambios')),
      );
    }
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

  Widget _buildAutoCompleteDirector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Autocomplete<String>(
        initialValue: TextEditingValue(text: directorController.text),
        optionsBuilder: (TextEditingValue textEditingValue) {
          return _directoresDisponibles.where((String option) {
            return option.toLowerCase().contains(
              textEditingValue.text.toLowerCase(),
            );
          });
        },
        onSelected: (String selection) {
          directorController.text = selection;
        },
        fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
          directorController = controller;
          return TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: const InputDecoration(
              labelText: 'Director',
              border: OutlineInputBorder(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextFieldActores() {
    final listaActores =
        actoresController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Actores (selecciona múltiples):"),
        Wrap(
          spacing: 8,
          children:
              listaActores
                  .map(
                    (actor) => Chip(
                      label: Text(actor),
                      onDeleted: () {
                        listaActores.remove(actor);
                        setState(() {
                          actoresController.text = listaActores.join(', ');
                        });
                      },
                    ),
                  )
                  .toList(),
        ),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            return _actoresDisponibles.where((String option) {
              return option.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  ) &&
                  !listaActores.contains(option);
            });
          },
          onSelected: (String selection) {
            listaActores.add(selection);
            setState(() {
              actoresController.text = listaActores.join(', ');
            });
          },
          fieldViewBuilder: (
            context,
            controller,
            focusNode,
            onEditingComplete,
          ) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: const InputDecoration(
                labelText: 'Agregar actor',
                border: OutlineInputBorder(),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Película')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField(tituloController, 'Título'),
            _buildTextField(generoController, 'Género'),
            _buildTextField(lanzamientoController, 'Año de Lanzamiento'),
            _buildTextField(sinopsisController, 'Sinopsis'),
            _buildTextField(duracionController, 'Duración'),
            _buildTextField(calificacionController, 'Calificación'),
            _buildAutoCompleteDirector(),
            const SizedBox(height: 12),
            _buildTextFieldActores(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _guardarCambios,
              child: const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
