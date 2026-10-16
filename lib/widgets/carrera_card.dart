import 'package:flutter/material.dart';
import 'package:proyecto_kania/ObjectsFirebase/carrera.dart';

class CarreraCard extends StatelessWidget {
  final Carrera carrera;

  const CarreraCard({
    super.key,
    required this.carrera,
  });

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFE54622);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner de imagen con fecha (Imagen por defecto: imagen_de_carrera.jpg)
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.asset(
                  'assets/images/imagen_de_carrera.jpg',
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(height: 160, color: const Color(0xFF222222)),
                ),
              ),
              // Badge de Categoría
              Positioned(
                left: 16,
                top: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(180),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'SWS RACE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
              // Badge de Fecha desde Firestore
              if (carrera.fecha.isNotEmpty)
                Positioned(
                  right: 16,
                  top: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: primaryOrange,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      carrera.fecha,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Cuerpo con información y botón de inscripción
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre de la carrera desde Firestore
                Text(
                  carrera.nombre,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                const Divider(color: Color(0xFFEEEEEE), height: 1),
                const SizedBox(height: 12),

                // Circuito y Botón Inscribirme vinculado a Firestore
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3F3F3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.sports_motorsports_outlined,
                        color: primaryOrange,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        carrera.circuito,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    // Botón de Inscripción dinámico con Firestore
                    StreamBuilder<bool>(
                      stream: Carrera.estaInscritoStream(
                        carrera.uid.isNotEmpty ? carrera.uid : carrera.nombre.replaceAll(' ', '_'),
                      ),
                      builder: (context, snapshot) {
                        final estaInscrito = snapshot.data ?? false;

                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: estaInscrito ? Colors.green : primaryOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () async {
                            final fueInscrito = await Carrera.alternarInscripcion(carrera);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    fueInscrito
                                        ? '¡Te has inscrito a ${carrera.nombre}!'
                                        : 'Has cancelado tu inscripción.',
                                  ),
                                  backgroundColor: fueInscrito ? Colors.green : Colors.grey[800],
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          child: Text(
                            estaInscrito ? 'Inscrito ✓' : 'Inscribirme',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
