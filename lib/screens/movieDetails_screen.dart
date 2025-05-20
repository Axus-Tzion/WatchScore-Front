import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watchscorefront/screens/editMovie_screen.dart';

class MovieDetailScreen extends StatefulWidget {
  final Map<String, dynamic> movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late Map<String, dynamic> movie;
  int? _usuarioId;
  bool _cargandoListas = false;
  bool _anadiendoALista = false;

  @override
  void initState() {
    super.initState();
    movie = widget.movie;
    _obtenerIdUsuario();
  }

  Future<void> _obtenerIdUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _usuarioId = prefs.getInt('userId');
    });
  }

  void _confirmarEliminacion() async {
    final confirmacion = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: const Text(
              '¿Estás seguro de que deseas eliminar esta película?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );

    if (confirmacion == true) {
      await _eliminarMovie();
    }
  }

  Future<void> _eliminarMovie() async {
    final id = movie['id'];
    final url = Uri.parse(
      'https://watchscore-1.onrender.com/peliculas/eliminar/$id',
    );

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (mounted) {
          Navigator.pop(context, {'eliminado': true});
        }
      } else {
        _mostrarError('Error al eliminar la película. Intenta de nuevo.');
      }
    } catch (e) {
      _mostrarError('Error de conexión al eliminar la película.');
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

  void _mostrarDialogoAnadirALista() async {
    if (_usuarioId == null) {
      _mostrarError('Debes iniciar sesión para usar listas');
      return;
    }

    setState(() => _cargandoListas = true);
    final listas = await _obtenerListasUsuario();
    setState(() => _cargandoListas = false);

    final TextEditingController _nombreListaController =
        TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Añadir a lista'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_cargandoListas)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        )
                      else if (listas.isNotEmpty) ...[
                        const Text(
                          'Selecciona una lista existente:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: listas.length,
                            itemBuilder: (context, index) {
                              final lista = listas[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: ListTile(
                                  title: Text(lista['nombre']),
                                  trailing: const Icon(Icons.arrow_forward),
                                  onTap: () {
                                    _anadirALista(lista['nombre']);
                                    Navigator.pop(context);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        const Divider(),
                      ],
                      const Text(
                        'O crea una nueva lista:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _nombreListaController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre de la lista',
                          border: OutlineInputBorder(),
                          hintText: 'Ej: Favoritas, Por ver...',
                        ),
                        onChanged: (value) => setState(() {}),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed:
                        _nombreListaController.text.isEmpty
                            ? null
                            : () {
                              _crearListaYanadir(_nombreListaController.text);
                              Navigator.pop(context);
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Crear y añadir'),
                  ),
                ],
              );
            },
          ),
    );
  }

  Future<List<Map<String, dynamic>>> _obtenerListasUsuario() async {
    try {
      final url = Uri.parse('https://watchscore-1.onrender.com/listas/mis');

      final response = await http.post(
        url,
        body: {'idusuario': _usuarioId.toString()},
      );

      if (response.statusCode == 200) {
        final List<dynamic> listasJson = json.decode(response.body);
        return listasJson
            .map((lista) => {'id': lista['id'], 'nombre': lista['nombre']})
            .toList();
      } else {
        _mostrarError('Error al obtener las listas: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      _mostrarError('Error de conexión: $e');
      return [];
    }
  }

  Future<void> _anadirALista(String nombreLista) async {
    if (_usuarioId == null) return;

    setState(() => _anadiendoALista = true);

    try {
      final url = Uri.parse(
        'https://watchscore-1.onrender.com/listas/agregar/$nombreLista/peliculas/${Uri.encodeComponent(movie['titulo'])}',
      );

      final response = await http.post(
        url,
        body: {'idusuario': _usuarioId.toString()},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Añadido a "$nombreLista" correctamente'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        _mostrarError('Error al añadir a la lista: ${response.body}');
      }
    } catch (e) {
      _mostrarError('Error de conexión: $e');
    } finally {
      if (mounted) {
        setState(() => _anadiendoALista = false);
      }
    }
  }

  Future<void> _crearListaYanadir(String nombreLista) async {
    if (_usuarioId == null) return;

    setState(() => _anadiendoALista = true);

    try {
      final crearUrl = Uri.parse(
        'https://watchscore-1.onrender.com/listas/usuario',
      );
      final crearResponse = await http.post(
        crearUrl,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'idusuario': _usuarioId, 'nombre': nombreLista}),
      );

      if (crearResponse.statusCode == 200 || crearResponse.statusCode == 201) {
        await _anadirALista(nombreLista);
      } else {
        _mostrarError('Error al crear la lista: ${crearResponse.body}');
      }
    } catch (e) {
      _mostrarError('Error de conexión: $e');
    } finally {
      if (mounted) {
        setState(() => _anadiendoALista = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> actores = movie['actores'] ?? [];
    final director = movie['director'];
    final bool isDirectorMap = director is Map;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Detalles de la Película'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.deepPurple[50],
                  child: const Icon(
                    Icons.movie,
                    size: 60,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  movie['titulo'] ?? 'Sin título',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  '${movie['genero'] ?? 'Género desconocido'} · ${movie['lanzamiento'] ?? 'Año desconocido'}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
                InkWell(
                  onTap:
                      isDirectorMap
                          ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => PersonDetailScreen(
                                      person: Map<String, dynamic>.from(
                                        director,
                                      ),
                                      type: 'Director',
                                    ),
                              ),
                            );
                          }
                          : null,
                  child: Text(
                    'Director: ${isDirectorMap ? director['nombre'] ?? 'Desconocido' : director ?? 'Desconocido'}',
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          isDirectorMap ? Colors.deepPurple : Colors.grey[700],
                      decoration:
                          isDirectorMap ? TextDecoration.underline : null,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sinopsis',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        movie['sipnosis'] ?? 'No disponible',
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Icon(
                            Icons.timer,
                            size: 20,
                            color: Colors.deepPurple,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Duración: ${movie['duracion'] ?? 'Desconocida'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 20,
                            color: Colors.deepPurple,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Calificación: ${movie['calificacion'] ?? 'Desconocida'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (actores.isNotEmpty) ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Actores',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children:
                        actores.map<Widget>((actor) {
                          final bool isActorMap = actor is Map;
                          final nombre =
                              isActorMap ? actor['nombre'] : actor.toString();

                          return InkWell(
                            onTap:
                                isActorMap
                                    ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => PersonDetailScreen(
                                                person:
                                                    Map<String, dynamic>.from(
                                                      actor,
                                                    ),
                                                type: 'Actor',
                                              ),
                                        ),
                                      );
                                    }
                                    : null,
                            child: Text(
                              nombre,
                              style: TextStyle(
                                color:
                                    isActorMap
                                        ? Colors.deepPurple
                                        : Colors.grey[700],
                                decoration:
                                    isActorMap
                                        ? TextDecoration.underline
                                        : null,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 30),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        final resultado = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditMovieScreen(movie: movie),
                          ),
                        );

                        if (resultado != null &&
                            resultado is Map<String, dynamic>) {
                          setState(() {
                            movie = resultado;
                          });
                        }
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text("Editar"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _confirmarEliminacion,
                      icon: const Icon(Icons.delete),
                      label: const Text("Eliminar"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _mostrarDialogoAnadirALista,
                      icon: const Icon(Icons.playlist_add),
                      label: const Text("A lista"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_anadiendoALista)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

class PersonDetailScreen extends StatelessWidget {
  final Map<String, dynamic> person;
  final String type;

  const PersonDetailScreen({
    super.key,
    required this.person,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final String nombre = person['nombre'] ?? 'Nombre no disponible';
    final String nacionalidad = person['nacionalidad'] ?? 'No disponible';
    final String fechaNacimiento = person['fechaNacimiento'] ?? 'No disponible';
    final String genero = person['genero'] ?? 'No especificado';
    final List<dynamic> trabajos =
        person['peliculas'] ?? person['series'] ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(nombre), backgroundColor: Colors.deepPurple),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(width: 10),
                Chip(
                  label: Text(type),
                  backgroundColor: Colors.deepPurple[50],
                  labelStyle: const TextStyle(color: Colors.deepPurple),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _InfoRow(label: 'Nacionalidad', value: nacionalidad),
            _InfoRow(label: 'Fecha de nacimiento', value: fechaNacimiento),
            _InfoRow(label: 'Género', value: genero),
            const SizedBox(height: 20),
            if (trabajos.isNotEmpty) ...[
              Text(
                type == 'Actor' ? 'Películas/Series' : 'Películas dirigidas',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 10),
              ...trabajos.map((trabajo) {
                String titulo =
                    trabajo is Map
                        ? trabajo['titulo'] ?? trabajo.toString()
                        : trabajo.toString();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '• $titulo',
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
