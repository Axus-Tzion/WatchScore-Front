import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditSerieScreen extends StatefulWidget {
  final Map<String, dynamic> serie;

  const EditSerieScreen({super.key, required this.serie});

  @override
  State<EditSerieScreen> createState() => _EditSerieScreenState();
}

class _EditSerieScreenState extends State<EditSerieScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _tituloController;
  late TextEditingController _generoController;
  late TextEditingController _lanzamientoController;
  late TextEditingController _sinopsisController;
  late TextEditingController _temporadasController;
  late TextEditingController _capitulosController;
  late TextEditingController _duracionCapituloController;
  late TextEditingController _calificacionController;

  @override
  void initState() {
    super.initState();
    final serie = widget.serie;
    _tituloController = TextEditingController(text: serie['titulo'] ?? '');
    _generoController = TextEditingController(text: serie['genero'] ?? '');
    _lanzamientoController = TextEditingController(
      text: serie['lanzamiento']?.toString() ?? '',
    );
    _sinopsisController = TextEditingController(text: serie['sinopsis'] ?? '');
    _temporadasController = TextEditingController(
      text: serie['temporadas']?.toString() ?? '',
    );
    _capitulosController = TextEditingController(
      text: serie['capitulos']?.toString() ?? '',
    );
    _duracionCapituloController = TextEditingController(
      text: serie['duracionCapitulo'] ?? '',
    );
    _calificacionController = TextEditingController(
      text: serie['calificacion']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _generoController.dispose();
    _lanzamientoController.dispose();
    _sinopsisController.dispose();
    _temporadasController.dispose();
    _capitulosController.dispose();
    _duracionCapituloController.dispose();
    _calificacionController.dispose();
    super.dispose();
  }

  void _guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      final id = widget.serie['id']; // Asegúrate de tener el ID

      final serieActualizada = {
        'titulo': _tituloController.text,
        'genero': _generoController.text,
        'lanzamiento': int.tryParse(_lanzamientoController.text),
        'sinopsis': _sinopsisController.text,
        'temporadas': int.tryParse(_temporadasController.text),
        'capitulos': int.tryParse(_capitulosController.text),
        'duracionCapitulo': _duracionCapituloController.text,
        'calificacion': double.tryParse(_calificacionController.text),
      };

      final url = Uri.parse('http://localhost:8080/api/series/$id');

      try {
        final response = await http.put(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(serieActualizada),
        );

        if (response.statusCode == 200) {
          Navigator.pop(context, jsonDecode(response.body));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al guardar los cambios.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error de conexión: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Serie'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_tituloController, 'Título'),
              _buildTextField(_generoController, 'Género'),
              _buildTextField(
                _lanzamientoController,
                'Año de lanzamiento',
                tipo: TextInputType.number,
              ),
              _buildTextField(_sinopsisController, 'Sinopsis', maxLines: 4),
              _buildTextField(
                _temporadasController,
                'Temporadas',
                tipo: TextInputType.number,
              ),
              _buildTextField(
                _capitulosController,
                'Capítulos',
                tipo: TextInputType.number,
              ),
              _buildTextField(
                _duracionCapituloController,
                'Duración por capítulo',
              ),
              _buildTextField(
                _calificacionController,
                'Calificación',
                tipo: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _guardarCambios,
                icon: const Icon(Icons.save),
                label: const Text('Guardar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType tipo = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: tipo,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Este campo es obligatorio';
          }
          return null;
        },
      ),
    );
  }
}
