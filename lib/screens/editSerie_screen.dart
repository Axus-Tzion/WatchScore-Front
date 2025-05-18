import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditSerieScreen extends StatefulWidget {
  final Map<String, dynamic> serie;

  const EditSerieScreen({Key? key, required this.serie}) : super(key: key);

  @override
  State<EditSerieScreen> createState() => _EditSerieScreenState();
}

class _EditSerieScreenState extends State<EditSerieScreen> {
  late TextEditingController tituloController;
  late TextEditingController generoController;
  late TextEditingController lanzamientoController;
  late TextEditingController sinopsisController;
  late TextEditingController duracionController;
  late TextEditingController temporadasController;
  late TextEditingController capitulosController;
  late TextEditingController calificacionController;
  late TextEditingController directorController;
  late TextEditingController actoresController;

  List<String> _actoresDisponibles = [];
  List<String> _directoresDisponibles = [];

  @override
  void initState() {
    super.initState();
    final serie = widget.serie;

    tituloController = TextEditingController(text: serie['titulo']);
    generoController = TextEditingController(text: serie['genero']);
    lanzamientoController = TextEditingController(
      text: serie['lanzamiento'].toString(),
    );
    sinopsisController = TextEditingController(text: serie['sinopsis']);
    temporadasController = TextEditingController(
      text: serie['temporadas'].toString(),
    );
    capitulosController = TextEditingController(
      text: serie['capitulos'].toString(),
    );
    duracionController = TextEditingController(
      text: serie['duracionCapitulo'].toString(),
    );

    calificacionController = TextEditingController(
      text: serie['calificacion'].toString(),
    );

    final director = serie['director'];
    directorController = TextEditingController(
      text: director is Map ? director['nombre'] ?? '' : director ?? '',
    );

    final actores = serie['actores'] as List;
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
    final id = widget.serie['id'];
    final url = Uri.parse('https://watchscore-1.onrender.com/actualizar/$id');

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'titulo': tituloController.text,
        'genero': generoController.text,
        'lanzamiento': lanzamientoController.text,
        'sinopsis': sinopsisController.text,
        'temporadas': temporadasController.text,
        'capitulos': capitulosController.text,
        'duracionCapitulo': duracionController.text,
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
      appBar: AppBar(title: const Text('Editar Serie')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField(tituloController, 'Título'),
            _buildTextField(generoController, 'Género'),
            _buildTextField(lanzamientoController, 'Año de Lanzamiento'),
            _buildTextField(sinopsisController, 'Sinopsis'),
            _buildTextField(temporadasController, 'Temporadas'),
            _buildTextField(capitulosController, 'Capitulos'),
            _buildTextField(duracionController, 'Duración Capitulo'),
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
