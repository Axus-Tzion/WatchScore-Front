import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

class MoviesRegister extends StatefulWidget {
  const MoviesRegister({super.key});

  @override
  State<MoviesRegister> createState() => _MoviesRegisterState();
}

class _MoviesRegisterState extends State<MoviesRegister> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _directorController = TextEditingController();
  final TextEditingController _lanzamientoController = TextEditingController();
  final TextEditingController _generoController = TextEditingController();
  final TextEditingController _sipnosisController = TextEditingController();
  final TextEditingController _calificacionController = TextEditingController();
  final TextEditingController _duracionController = TextEditingController();
  final TextEditingController _actorInputController = TextEditingController();

  bool _isLoading = false;
  String? _generoSeleccionado;
  List<String> _actores = [];
  List<String> _sugerencias = [];

  final List<String> _generos = [
    'Acción',
    'Aventura',
    'Comedia',
    'Drama',
    'Fantasía',
    'Terror',
    'Ciencia Ficción',
    'Romance',
    'Suspenso',
    'Animación',
    'Documental',
  ];

  // crea el calendario
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _lanzamientoController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // consume el api de los actores
  Future<void> _cargarActores() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8860/actores/'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _sugerencias =
              data.map((actor) => actor['nombre'].toString()).toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: ${e.toString()}')),
      );
    }
  }

  // valida que los campos no esten vacios
  Future<void> _moviesRegister(BuildContext) async {
    if (_tituloController.text.isEmpty ||
        _directorController.text.isEmpty ||
        _lanzamientoController.text.isEmpty ||
        _generoSeleccionado == null ||
        _sipnosisController.text.isEmpty ||
        _duracionController.text.isEmpty ||
        _actores.isEmpty ||
        _calificacionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor complete todos los campos')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // consume la api del registro de peliculas
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8860/peliculas/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'titulo': _tituloController.text,
          'director': _directorController.text,
          'lanzamiento': _lanzamientoController.text,
          'genero': _generoSeleccionado,
          'duracion': _duracionController.text,
          'sipnosis': _sipnosisController.text,
          'calificacion': _calificacionController.text,
          'actores': _actores,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro de película exitoso')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MoviesRegister()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error en registro: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _cargarActores();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      appBar: AppBar(
        title: const Text(
          'Registrar Película',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Título',
                prefixIcon: Icon(Icons.segment, color: Colors.deepPurple),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _directorController,
              decoration: const InputDecoration(
                labelText: 'Director',
                prefixIcon: Icon(Icons.person, color: Colors.deepPurple),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _duracionController,
              decoration: const InputDecoration(
                labelText: 'Duración',
                prefixIcon: Icon(
                  Icons.access_alarms_outlined,
                  color: Colors.deepPurple,
                ),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: _generoSeleccionado,
              items:
                  _generos.map((String genero) {
                    return DropdownMenuItem<String>(
                      value: genero,
                      child: Text(genero),
                    );
                  }).toList(),
              onChanged: (String? nuevoValor) {
                setState(() {
                  _generoSeleccionado = nuevoValor;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Género',
                prefixIcon: Icon(
                  Icons.theater_comedy_outlined,
                  color: Colors.deepPurple,
                ),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _calificacionController,
              decoration: const InputDecoration(
                labelText: 'Calificación',
                prefixIcon: Icon(Icons.numbers, color: Colors.deepPurple),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _lanzamientoController,
              decoration: const InputDecoration(
                labelText: 'Fecha de Lanzamiento',
                prefixIcon: Icon(
                  Icons.calendar_today,
                  color: Colors.deepPurple,
                ),
                border: OutlineInputBorder(),
              ),
              onTap: () => _selectDate(context),
              readOnly: true,
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _sipnosisController,
              decoration: const InputDecoration(
                labelText: 'Sinopsis',
                prefixIcon: Icon(Icons.chat_outlined, color: Colors.deepPurple),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<String>.empty();
                }
                return _sugerencias.where((String option) {
                  return option.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  );
                });
              },
              onSelected: (String selection) {
                if (!_actores.contains(selection)) {
                  setState(() {
                    _actores.add(selection);
                    _actorInputController.clear();
                  });
                }
              },
              fieldViewBuilder: (
                context,
                controller,
                focusNode,
                onFieldSubmitted,
              ) {
                _actorInputController.text = controller.text;
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Buscar Actores',
                    prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
                    border: OutlineInputBorder(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              children:
                  _actores.map((actor) {
                    return Chip(
                      label: Text(actor),
                      deleteIcon: const Icon(Icons.close),
                      onDeleted: () {
                        setState(() {
                          _actores.remove(actor);
                        });
                      },
                    );
                  }).toList(),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _isLoading ? null : () => _moviesRegister(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
              ),
              child:
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                        'Registrar la película',
                        style: TextStyle(color: Colors.white),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
