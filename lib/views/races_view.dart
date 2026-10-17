import 'package:flutter/material.dart';
import 'package:proyecto_kania/ObjectsFirebase/carrera.dart';
import 'package:proyecto_kania/ObjectsFirebase/circuito.dart';
import 'package:proyecto_kania/widgets/carrera_card.dart';
import 'package:proyecto_kania/widgets/races_header_banner.dart';
import 'package:proyecto_kania/widgets/races_tab_selector.dart';

class RacesView extends StatefulWidget {
  const RacesView({super.key});

  @override
  State<RacesView> createState() => _RacesViewState();
}

class _RacesViewState extends State<RacesView> {
  int _selectedTab = 0; // 0: Próximas, 1: Mis carreras

  void _mostrarDialogoCrearCarrera(BuildContext context) {
    final nombreController = TextEditingController();
    final fechaController = TextEditingController();
    String? circuitoSeleccionado;
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1B1B1B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Crear nueva carrera',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nombreController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Nombre de la carrera',
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: const Color(0xFF262626),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Introduce el nombre' : null,
                      ),
                      const SizedBox(height: 12),
                      
                      // Seleccionable de Circuitos desde Firestore
                      FutureBuilder<List<Circuito>>(
                        future: Circuito.obtenerCircuitosFirestore(),
                        builder: (context, snapshot) {
                          final circuitos = snapshot.data ?? [];
                          final nombres = circuitos.map((c) => c.nombre).where((n) => n.isNotEmpty).toSet().toList();
                          
                          if (nombres.isEmpty) {
                            nombres.addAll(['Karting Cabanillas', 'Henakart', 'Karting Los Santos']);
                          }

                          return DropdownButtonFormField<String>(
                            initialValue: circuitoSeleccionado,
                            dropdownColor: const Color(0xFF262626),
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Selecciona un Circuito',
                              labelStyle: const TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: const Color(0xFF262626),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: nombres.map((nombreCircuito) {
                              return DropdownMenuItem<String>(
                                value: nombreCircuito,
                                child: Text(
                                  nombreCircuito,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setDialogState(() {
                                circuitoSeleccionado = value;
                              });
                            },
                            validator: (v) => v == null || v.isEmpty ? 'Selecciona un circuito' : null,
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: fechaController,
                        readOnly: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Selecciona la fecha',
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(Icons.calendar_month, color: Color(0xFFE54622)),
                          filled: true,
                          fillColor: const Color(0xFF262626),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2030),
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.dark().copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: Color(0xFFE54622),
                                    onPrimary: Colors.white,
                                    surface: Color(0xFF1B1B1B),
                                    onSurface: Colors.white,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            const meses = [
                              'ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN',
                              'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'
                            ];
                            final dia = picked.day.toString().padLeft(2, '0');
                            final mes = meses[picked.month - 1];
                            setDialogState(() {
                              fechaController.text = '$dia $mes';
                            });
                          }
                        },
                        validator: (v) => v == null || v.isEmpty ? 'Selecciona una fecha válida' : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.white60)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE54622),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            setDialogState(() {
                              isLoading = true;
                            });
                            try {
                              await Carrera.crearCarrera(
                                nombre: nombreController.text.trim(),
                                circuito: circuitoSeleccionado ?? 'Karting Cabanillas',
                                fecha: fechaController.text.trim(),
                              );
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Carrera añadida a Firestore con éxito'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error al crear carrera: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } finally {
                              setDialogState(() {
                                isLoading = false;
                              });
                            }
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Crear'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFE54622);
    const lightBackground = Color(0xFFF3F3F3);

    return Scaffold(
      backgroundColor: lightBackground,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarDialogoCrearCarrera(context),
        backgroundColor: primaryOrange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Crear Carrera',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Menu Top Button
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.menu, color: Colors.black87),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Menú principal de Carreras')),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2. Hero Header Banner con contador dinámico de Firestore (Solo para Próximas carreras)
              if (_selectedTab == 0) ...[
                StreamBuilder<List<Carrera>>(
                  stream: Carrera.obtenerCarrerasStream(),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.length ?? 0;
                    return RacesHeaderBanner(totalCarreras: count);
                  },
                ),
                const SizedBox(height: 20),
              ],

              // 3. Tab Selector (Próximas / Mis carreras)
              RacesTabSelector(
                selectedTab: _selectedTab,
                onTabSelected: (tabIndex) {
                  setState(() {
                    _selectedTab = tabIndex;
                  });
                },
              ),
              const SizedBox(height: 24),

              // 4. Section Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedTab == 0 ? 'CALENDARIO OFICIAL' : 'TU HISTORIAL',
                        style: const TextStyle(
                          color: primaryOrange,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _selectedTab == 0 ? 'Próximas carreras' : 'Mis inscripciones',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.tune, color: Colors.black87, size: 20),
                      onPressed: () => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 5. Listas separadas en tiempo real con Firestore
              _selectedTab == 0
                  ? StreamBuilder<List<Carrera>>(
                      stream: Carrera.obtenerCarrerasStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(color: primaryOrange),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              color: Colors.red.withAlpha(20),
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(color: Colors.redAccent),
                            ),
                            child: Text(
                              'Error al cargar carreras: ${snapshot.error}',
                              style: const TextStyle(color: Colors.redAccent),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        final todasLasCarreras = snapshot.data ?? [];

                        if (todasLasCarreras.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(28.0),
                            margin: const EdgeInsets.symmetric(vertical: 16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Column(
                              children: const [
                                Icon(Icons.flag_outlined, size: 48, color: Colors.black38),
                                SizedBox(height: 12),
                                Text(
                                  'No hay carreras registradas en Firestore',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Pulsa el botón "+ Crear Carrera" para añadir tu primera prueba.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black54, fontSize: 13),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: todasLasCarreras.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            return CarreraCard(carrera: todasLasCarreras[index]);
                          },
                        );
                      },
                    )
                  : StreamBuilder<List<Carrera>>(
                      stream: Carrera.obtenerMisCarrerasStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(color: primaryOrange),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              color: Colors.red.withAlpha(20),
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(color: Colors.redAccent),
                            ),
                            child: Text(
                              'Error al cargar tus carreras: ${snapshot.error}',
                              style: const TextStyle(color: Colors.redAccent),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        final misCarreras = snapshot.data ?? [];

                        if (misCarreras.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(28.0),
                            margin: const EdgeInsets.symmetric(vertical: 16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Column(
                              children: const [
                                Icon(Icons.bookmark_outline, size: 48, color: Colors.black38),
                                SizedBox(height: 12),
                                Text(
                                  'Aún no te has inscrito en ninguna carrera',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Pulsa "Inscribirme" en cualquiera de las próximas pruebas para guardarla aquí.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black54, fontSize: 13),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: misCarreras.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            return CarreraCard(carrera: misCarreras[index]);
                          },
                        );
                      },
                    ),

              // 6. Bottom Banner Card (Solo para Próximas carreras)
              if (_selectedTab == 0) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF181818),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              '¿Buscas otra fecha?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Explora el calendario completo de carreras.',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: primaryOrange,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 80), // Espacio para el FloatingActionButton
            ],
          ),
        ),
      ),
    );
  }
}
