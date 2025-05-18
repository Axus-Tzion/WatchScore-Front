import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditSerieScreen extends StatefulWidget {
  final int serie;

  const EditSerieScreen({super.key, required this.serie});

  @override
  State<EditSerieScreen> createState() => _EditSerieScreenState();
}

class _EditSerieScreenState extends State<EditSerieScreen> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> serieData = {};
  bool isLoading = true;

  final TextEditingController tituloController = TextEditingController();
  final TextEditingController generoController = TextEditingController();
  final TextEditingController lanzamientoController = TextEditingController();
  final TextEditingController sinopsisController = TextEditingController();
  final TextEditingController temporadasController = TextEditingController();
  final TextEditingController capitulosController = TextEditingController();
  final TextEditingController duracionCapituloController =
      TextEditingController();
  final TextEditingController calificacionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSerie();
  }

  Future<void> _fetchSerie() async {
    final url = Uri.parse('http://localhost:8860/series/id/${widget.serie}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        serieData = jsonDecode(response.body);
        tituloController.text = serieData['titulo'] ?? '';
        generoController.text = serieData['genero'] ?? '';
        lanzamientoController.text = serieData['lanzamiento']?.toString() ?? '';
        sinopsisController.text = serieData['sinopsis'] ?? '';
        temporadasController.text = serieData['temporadas']?.toString() ?? '';
        capitulosController.text = serieData['capitulos']?.toString() ?? '';
        duracionCapituloController.text =
            serieData['duracionCapitulo']?.toString() ?? '';
        calificacionController.text =
            serieData['calificacion']?.toString() ?? '';
        setState(() {
          isLoading = false;
        });
      } else {
        _showError('Error al obtener los datos de la serie.');
      }
    } catch (e) {
      _showError('No se pudo conectar con el servidor.');
    }
  }

  Future<void> _guardarCambios() async {
    if (_formKey.currentState?.validate() != true) return;

    final url = Uri.parse(
      'http://localhost:8860/series/actualizar/${widget.serie}',
    );
    final updatedData = {
      'titulo': tituloController.text,
      'genero': generoController.text,
      'lanzamiento': int.tryParse(lanzamientoController.text),
      'sinopsis': sinopsisController.text,
      'temporadas': int.tryParse(temporadasController.text),
      'capitulos': int.tryParse(capitulosController.text),
      'duracionCapitulo': int.tryParse(duracionCapituloController.text),
      'calificacion': double.tryParse(calificacionController.text),
    };

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        final updatedSerie = jsonDecode(response.body);
        if (mounted) Navigator.pop(context, updatedSerie);
      } else {
        _showError('Error al guardar los cambios.');
      }
    } catch (e) {
      _showError('Error de conexión al guardar cambios.');
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
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
        title: const Text('Editar Serie'),
        backgroundColor: Colors.deepPurple,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      _buildField(tituloController, 'Título'),
                      _buildField(generoController, 'Género'),
                      _buildField(
                        lanzamientoController,
                        'Año de lanzamiento',
                        isNumber: true,
                      ),
                      _buildField(sinopsisController, 'Sinopsis', maxLines: 3),
                      _buildField(
                        temporadasController,
                        'Temporadas',
                        isNumber: true,
                      ),
                      _buildField(
                        capitulosController,
                        'Capítulos',
                        isNumber: true,
                      ),
                      _buildField(
                        duracionCapituloController,
                        'Duración por capítulo (min)',
                        isNumber: true,
                      ),
                      _buildField(
                        calificacionController,
                        'Calificación',
                        isDecimal: true,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _guardarCambios,
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar Cambios'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
    bool isDecimal = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType:
            isNumber || isDecimal ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
