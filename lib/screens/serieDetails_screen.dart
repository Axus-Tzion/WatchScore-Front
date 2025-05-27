import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:watchscorefront/screens/editSerie_screen.dart';

class SerieDetailScreen extends StatefulWidget {
  final Map<String, dynamic> serie;
  final Map<String, dynamic> userData;

  const SerieDetailScreen({
    super.key,
    required this.serie,
    required this.userData,
  });

  @override
  State<SerieDetailScreen> createState() => _SerieDetailScreenState();
}

class _SerieDetailScreenState extends State<SerieDetailScreen> {
  late Map<String, dynamic> serie;
  final TextEditingController _nombreListaController = TextEditingController();
  List<Map<String, dynamic>> _listasUsuario = [];
  List<dynamic> resenas = [];
  bool _creandoNuevaLista = false;
  bool cargandoResenas = true;

  @override
  void initState() {
    super.initState();
    serie = widget.serie;
    _cargarResenas();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ModalRoute.of(context)?.isCurrent == false) {
        _recargarDatos();
      }
    });
  }

  Future<void> _recargarDatos() async {
    // Puedes hacer una nueva petición al servidor para asegurarte de tener los datos más actualizados
    try {
      final response = await http.get(
        Uri.parse('https://watchscore-1.onrender.com/series/${serie['id']}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          serie = data;
        });
      }
    } catch (e) {
      print('Error al recargar datos: $e');
    }

    // También recarga las reseñas
    await _cargarResenas();
  }

  Future<void> _cargarResenas() async {
    setState(() => cargandoResenas = true);
    try {
      final serieTitulo = serie['titulo'];
      print('Buscando reseñas para: $serieTitulo');

      final url = Uri.parse(
        'https://watchscore-1.onrender.com/resenas/series/$serieTitulo',
      );

      final response = await http.get(url);
      print('Código de respuesta: ${response.statusCode}');
      print('Cuerpo de respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Datos recibidos: $data');

        setState(() {
          resenas = List<dynamic>.from(data);
          print('Reseñas cargadas: ${resenas.length}');
        });
      } else {
        throw Exception('Error al cargar reseñas: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al cargar reseñas: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar reseñas: $e')));
    } finally {
      setState(() => cargandoResenas = false);
    }
  }

  void _mostrarDialogoCrearResena() {
    final TextEditingController comentarioController = TextEditingController();
    final TextEditingController calificacionController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Reseña'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: comentarioController,
                  decoration: const InputDecoration(labelText: 'Comentario'),
                  maxLines: 3,
                ),
                TextField(
                  controller: calificacionController,
                  decoration: const InputDecoration(
                    labelText: 'Calificación (1-5)',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final usuario = widget.userData['nombre'];
                final comentario = comentarioController.text.trim();
                final calificacion = int.tryParse(
                  calificacionController.text.trim(),
                );

                if (usuario.isEmpty ||
                    comentario.isEmpty ||
                    calificacion == null ||
                    calificacion < 1 ||
                    calificacion > 5) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Por favor, completa todos los campos correctamente.',
                      ),
                    ),
                  );
                  return;
                }

                try {
                  final tituloSerie = serie['titulo'];
                  final userIdentificacion = widget.userData['identificacion'];

                  final response = await http.post(
                    Uri.parse(
                      'https://watchscore-1.onrender.com/resenas/series/$tituloSerie/usuario/$userIdentificacion',
                    ),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'comentario': comentario,
                      'calificacion': calificacion,
                    }),
                  );

                  if (response.statusCode == 201) {
                    await _cargarResenas();
                    setState(() {});
                    Navigator.of(context).pop();

                    await Future.delayed(const Duration(milliseconds: 100));

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('¡Reseña guardada exitosamente!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    throw Exception('Error al guardar reseña');
                  }
                } catch (e) {
                  await _cargarResenas();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('¡Reseña guardada exitosamente!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
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

  Future<void> _agregarSerieALista(String listaNombre) async {
    final serieTitulo = serie['titulo'];
    final url = Uri.parse(
      'https://watchscore-1.onrender.com/listas/agregar/$listaNombre/series/$serieTitulo',
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
            content: Text('Serie agregada a la lista correctamente'),
          ),
        );
      } else {
        _mostrarError('Error al agregar la serie a la lista.');
      }
    } catch (e) {
      _mostrarError('Error de conexión al agregar la serie.');
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
                              _agregarSerieALista(listaSeleccionadaNombre!);
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
              '¿Estás segura de que deseas eliminar esta serie?',
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
      await _eliminarSerie();
    }
  }

  Future<void> _eliminarSerie() async {
    final id = serie['id'];
    final url = Uri.parse(
      'https://watchscore-1.onrender.com/series/eliminar/$id',
    );

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (mounted) {
          await showDialog(
            context: context,
            builder:
                (_) => AlertDialog(
                  title: const Text('Eliminación exitosa'),
                  content: const Text(
                    'La serie ha sido eliminada correctamente.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Aceptar'),
                    ),
                  ],
                ),
          );
          if (mounted) Navigator.pop(context, true);
        }
      } else {
        _mostrarError('Error al eliminar la serie. Intenta de nuevo.');
      }
    } catch (e) {
      _mostrarError('Error de conexión al eliminar la serie.');
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
    final List<dynamic> actores = serie['actores'] ?? [];

    final director = serie['director'];
    final bool isDirectorMap = director is Map;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Detalle de Serie'),
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
              serie['titulo'] ?? 'Sin título',
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
              '${serie['genero'] ?? 'Género desconocido'} · ${serie['lanzamiento'] ?? 'Año desconocido'}',
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
                    serie['sinopsis'] ?? 'No disponible',
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
                          'Temporadas: ${serie['temporadas'] ?? 'Desconocidas'} · '
                          'Capítulos: ${serie['capitulos'] ?? 'Desconocido'} · '
                          'Duración por capítulo: ${serie['duracionCapitulo'] ?? 'Desconocido'}',
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
                        'Calificación: ${serie['calificacion'] ?? 'Desconocida'}',
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

            // Botones de acción
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final resultado = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditSerieScreen(serie: serie),
                      ),
                    );

                    if (resultado != null &&
                        resultado is Map<String, dynamic>) {
                      setState(() {
                        serie = resultado;
                      });
                      // Muestra un mensaje de confirmación
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Película actualizada correctamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
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

            const SizedBox(height: 30),

            // Sección Reseñas
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reseñas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple[700],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.deepPurple),
                    onPressed: _mostrarDialogoCrearResena,
                    tooltip: 'Agregar reseña',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (cargandoResenas)
              const Center(child: CircularProgressIndicator())
            else if (resenas.isEmpty)
              const Text('No hay reseñas aún')
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    resenas.map<Widget>((resena) {
                      final usuario = resena['nombreUsuario'] ?? 'Anónimo';
                      final comentario = resena['comentario'] ?? '';
                      final calificacion =
                          (resena['calificacion'] ?? 0).toDouble();

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              usuario,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: List.generate(5, (index) {
                                if (calificacion >= index + 1) {
                                  return const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  );
                                } else if (calificacion > index) {
                                  return const Icon(
                                    Icons.star_half,
                                    color: Colors.amber,
                                    size: 16,
                                  );
                                } else {
                                  return const Icon(
                                    Icons.star_border,
                                    color: Colors.amber,
                                    size: 16,
                                  );
                                }
                              }),
                            ),
                            const SizedBox(height: 6),
                            Text(comentario),
                          ],
                        ),
                      );
                    }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

// Pantalla de detalle de persona
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
    final List<dynamic> trabajos = person['series'] ?? [];

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
                type == 'Actor' ? 'Series/Películas' : 'Series dirigidas',
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

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.deepPurple,
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
