import 'package:flutter/material.dart';

class SerieDetailScreen extends StatelessWidget {
  final Map<String, dynamic> serie;

  const SerieDetailScreen({super.key, required this.serie});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> actores = serie['actores'] ?? [];

    // Obtener nombre del director, ya sea string o Map
    String nombreDirector = '';
    final director = serie['director'];
    if (director is Map) {
      nombreDirector = director['nombre'] ?? 'Desconocido';
    } else if (director is String) {
      nombreDirector = director;
    } else {
      nombreDirector = 'Desconocido';
    }

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
            // Icono de la serie
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

            // Género y Año
            Text(
              '${serie['genero'] ?? 'Género desconocido'} · ${serie['lanzamiento'] ?? 'Año desconocido'}',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),

            Text(
              'Director: $nombreDirector',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Sinopsis y datos técnicos
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

                  // Temporadas y capítulos
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

                  // Calificación
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
                      final nombre =
                          actor is Map ? actor['nombre'] : actor.toString();

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ActorDetailScreen(
                                    actor: actor,
                                  ), // ✅ objeto completo
                            ),
                          );
                        },
                        child: Chip(
                          label: Text(nombre),
                          backgroundColor: Colors.deepPurple[50],
                          labelStyle: const TextStyle(color: Colors.deepPurple),
                          avatar: const Icon(
                            Icons.person,
                            size: 18,
                            color: Colors.deepPurple,
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
                  onPressed: () {
                    // TODO: Acción editar
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
                  onPressed: () {
                    // TODO: Acción eliminar
                  },
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
                  onPressed: () {
                    // TODO: Acción agregar a lista
                  },
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

class ActorDetailScreen extends StatelessWidget {
  final dynamic actor;

  const ActorDetailScreen({super.key, required this.actor});

  @override
  Widget build(BuildContext context) {
    final String nombre = actor['nombre'] ?? 'Nombre no disponible';
    final String nacionalidad = actor['nacionalidad'] ?? 'No disponible';
    final String fechaNacimiento = actor['fechaNacimiento'] ?? 'No disponible';
    final String genero = actor['genero'] ?? 'No especificado';
    final List<dynamic> peliculas = actor['peliculas'] ?? [];
    final List<dynamic> series = actor['series'] ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(nombre), backgroundColor: Colors.deepPurple),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nombre,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),
            _infoItem("Nacionalidad", nacionalidad),
            _infoItem("Fecha de nacimiento", fechaNacimiento),
            _infoItem("Género", genero),
            const SizedBox(height: 20),
            _listSection("Películas", peliculas),
            const SizedBox(height: 20),
            _listSection("Series", series),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(String label, String value) {
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

  Widget _listSection(String title, List<dynamic> items) {
    if (items.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 10),
        ...items.map((item) {
          String titulo =
              item is Map && item.containsKey('titulo')
                  ? item['titulo']
                  : item.toString();
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text('• $titulo', style: const TextStyle(fontSize: 16)),
          );
        }).toList(),
      ],
    );
  }
}
