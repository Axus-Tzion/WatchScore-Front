import 'package:flutter/material.dart';

class MovieDetailScreen extends StatelessWidget {
  final Map<String, dynamic> movie;

  const MovieDetailScreen({super.key, required this.movie});

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icono de la película
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

            // Género y Año
            Text(
              '${movie['genero'] ?? 'Género desconocido'} · ${movie['lanzamiento'] ?? 'Año desconocido'}',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),

            // Director (clicable si es Map)
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
                    movie['sinopsis'] ?? 'No disponible',
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 20),

                  // Duración
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
                        'Calificación: ${movie['calificacion'] ?? 'Desconocida'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Actores (clicables)
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
                  onPressed: () {},
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
                  onPressed: () {},
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
                  onPressed: () {},
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

// Reutiliza la misma clase PersonDetailScreen de SerieDetailScreen
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
