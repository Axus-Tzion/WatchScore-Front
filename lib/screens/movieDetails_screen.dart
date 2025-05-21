import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:watchscorefront/screens/editMovie_screen.dart';
import 'package:watchscorefront/screens/editSerie_screen.dart';

class MovieDetailScreen extends StatefulWidget {
  final Map<String, dynamic> movie;
  final Map<String, dynamic> userData;

  const MovieDetailScreen({
    super.key,
    required this.movie,
    required this.userData,
  });

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late Map<String, dynamic> movie;
  final TextEditingController _nombreListaController = TextEditingController();
  List<Map<String, dynamic>> _listasUsuario = [];
  bool _creandoNuevaLista = false;

  @override
  void initState() {
    super.initState();
    movie = widget.movie;
  }

  Future<void> _cargarListasUsuario() async {
    final userId = widget.userData['identificacion'];
    final url = Uri.parse(
      'https://watchscore-1.onrender.com/listas/misListas/$userId',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _listasUsuario =
              data
                  .map<Map<String, dynamic>>(
                    (e) => Map<String, dynamic>.from(e),
                  )
                  .toList();
        });
      } else {
        _mostrarError('No se pudieron cargar las listas del usuario.');
      }
    } catch (e) {
      _mostrarError('Error de conexión al cargar las listas.');
    }
  }

  Future<void> _agregarPeliculaALista(String listaNombre) async {
    final peliculaTitulo = movie['titulo'];
    final url = Uri.parse(
      'https://watchscore-1.onrender.com/listas/agregar/$listaNombre/peliculas/$peliculaTitulo',
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Película agregada a la lista correctamente'),
          ),
        );
      } else {
        _mostrarError('Error al agregar la película a la lista.');
      }
    } catch (e) {
      _mostrarError('Error de conexión al agregar la película.');
    }
  }

  Future<void> _crearNuevaListaYAgregarPelicula(String nombreLista) async {
    final userId = widget.userData['identificacion'];
    final url = Uri.parse(
      'https://watchscore-1.onrender.com/listas/crear/$userId',
    );

    final body = json.encode({'nombre': nombreLista});

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lista creada exitosamente')),
        );
      } else {
        _mostrarError('Error al crear la nueva lista.');
      }
    } catch (e) {
      _mostrarError('Error de conexión al crear la lista.');
    }
  }

  Future<void> _mostrarDialogoListas() async {
    await _cargarListasUsuario();
    _creandoNuevaLista = false;
    _nombreListaController.clear();

    showDialog(
      context: context,
      builder: (context) {
        String? listaSeleccionadaNombre;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Agregar a lista'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!_creandoNuevaLista) ...[
                      if (_listasUsuario.isEmpty)
                        const Text(
                          'No tienes listas creadas. Puedes crear una nueva.',
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _listasUsuario.length,
                            itemBuilder: (context, index) {
                              final lista = _listasUsuario[index];
                              final nombre = lista['nombre'] ?? 'Sin nombre';

                              return RadioListTile<String>(
                                title: Text(nombre),
                                value: nombre,
                                groupValue: listaSeleccionadaNombre,
                                onChanged: (value) {
                                  setStateDialog(() {
                                    listaSeleccionadaNombre = value;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 10),
                      TextButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Crear nueva lista'),
                        onPressed: () {
                          setStateDialog(() {
                            _creandoNuevaLista = true;
                          });
                        },
                      ),
                    ],
                    if (_creandoNuevaLista) ...[
                      TextField(
                        controller: _nombreListaController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre de la nueva lista',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              setStateDialog(() {
                                _creandoNuevaLista = false;
                              });
                            },
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              final nombre = _nombreListaController.text.trim();
                              if (nombre.isNotEmpty) {
                                Navigator.pop(context);
                                _crearNuevaListaYAgregarPelicula(nombre);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'El nombre no puede estar vacío',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: const Text('Crear y agregar'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                if (!_creandoNuevaLista)
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                if (!_creandoNuevaLista)
                  ElevatedButton(
                    onPressed:
                        listaSeleccionadaNombre != null
                            ? () {
                              Navigator.pop(context);
                              _agregarPeliculaALista(listaSeleccionadaNombre!);
                            }
                            : null,
                    child: const Text('Agregar'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmarEliminacion() async {
    final confirmacion = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: const Text(
              '¿Estás segura de que deseas eliminar esta película?',
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

  @override
  Widget build(BuildContext context) {
    final List<dynamic> actores = movie['actores'] ?? [];
    final director = movie['director'];
    final bool isDirectorMap = director is Map;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Detalle de Pelicula'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icono
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.deepPurple[50],
              child: const Icon(Icons.tv, size: 60, color: Colors.deepPurple),
            ),
            const SizedBox(height: 20),

            // Título
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

            // Género y año
            Text(
              '${movie['genero'] ?? 'Género desconocido'} · ${movie['lanzamiento'] ?? 'Año desconocido'}',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),

            // Director
            InkWell(
              onTap:
                  isDirectorMap
                      ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => PersonDetailScreen(
                                  person: Map<String, dynamic>.from(director),
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
                  color: isDirectorMap ? Colors.deepPurple : Colors.grey[700],
                  decoration: isDirectorMap ? TextDecoration.underline : null,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

            // Detalles técnicos
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
                        Icons.list,
                        size: 20,
                        color: Colors.deepPurple,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Duración: ${movie['duracion'] ?? 'Desconocido'}',
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

            // Actores
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
                                            person: Map<String, dynamic>.from(
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
                                isActorMap ? TextDecoration.underline : null,
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
                  onPressed: _mostrarDialogoListas,
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
    final nombre = person['nombre'] ?? 'Desconocido';
    final nacionalidad = person['nacionalidad'] ?? 'Desconocida';
    final fechaNacimiento = person['fechaNacimiento'] ?? 'No especificada';
    final genero = person['genero'] ?? 'No especificado';

    final List<dynamic> seriesRaw = person['series'] ?? [];
    final List<String> series = seriesRaw.map((e) => e.toString()).toList();

    final List<dynamic> peliculasRaw = person['peliculas'] ?? [];
    final List<String> peliculas =
        peliculasRaw.map((e) => e.toString()).toList();

    // Debug prints
    print('Series raw: $seriesRaw');
    print('Películas raw: $peliculasRaw');

    return Scaffold(
      appBar: AppBar(title: Text('$type: $nombre')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              nombre,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Nacionalidad: $nacionalidad',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Fecha de nacimiento: $fechaNacimiento',
              style: const TextStyle(fontSize: 18),
            ),
            Text('Género: $genero', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Text(
              'Series relacionadas:',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ...series.isNotEmpty
                ? series
                    .map(
                      (serie) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          serie,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                    .toList()
                : [
                  const Text(
                    'No hay series relacionadas',
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  ),
                ],
            const SizedBox(height: 20),
            Text(
              'Películas relacionadas:',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ...peliculas.isNotEmpty
                ? peliculas
                    .map(
                      (pelicula) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          pelicula,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                    .toList()
                : [
                  const Text(
                    'No hay películas relacionadas',
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  ),
                ],
          ],
        ),
      ),
    );
  }
}
