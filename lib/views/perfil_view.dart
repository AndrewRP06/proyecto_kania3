import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_kania/Dataholder.dart';
import 'package:proyecto_kania/ObjectsFirebase/historial_circuito.dart';
import 'package:proyecto_kania/theme/AppTheme.dart';

class PerfilView extends StatefulWidget {
  const PerfilView({super.key});

  @override
  State<PerfilView> createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  bool _isLoading = true;
  final Dataholder _dh = Dataholder.instance;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    await _dh.loadUserData();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColores.oscuro,
        body: Center(
          child: CircularProgressIndicator(color: AppColores.principal),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColores.oscuro,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(context),
              _buildHeaderInfo(),
              const SizedBox(height: 24),
              _buildStatsContainer(),
              const SizedBox(height: 20),
              _buildMainContentContainer(),
            ],
          ),
        ),
      ),
    );
  }

  /// Barra superior con botones de Cerrar Sesión y Editar Perfil
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColores.error),
            onPressed: () async {
              await _dh.signOut();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
            tooltip: 'Cerrar sesión',
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF262626),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.white, size: 18),
              onPressed: () async {
                await Navigator.pushNamed(context, '/edit_profile');
                if (mounted) setState(() {});
              },
              tooltip: 'Editar perfil',
            ),
          ),
        ],
      ),
    );
  }

  /// Sección de Avatar e Información Personal del Piloto
  Widget _buildHeaderInfo() {
    Widget avatarWidget;
    if (_dh.perfilUsuario.avatar != null) {
      avatarWidget = _dh.perfilUsuario.avatar!;
    } else if (_dh.urlAvatar?.isNotEmpty == true) {
      avatarWidget = CircleAvatar(
        radius: 48,
        backgroundImage: NetworkImage(_dh.urlAvatar!),
      );
    } else {
      avatarWidget = const CircleAvatar(
        radius: 48,
        backgroundColor: AppColores.cardOscuro,
        child: Icon(
          Icons.person,
          size: 54,
          color: AppColores.principal,
        ),
      );
    }

    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColores.principal, width: 3),
                ),
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child: ClipOval(child: avatarWidget),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2ECC71),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColores.oscuro, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'PILOTO',
            style: TextStyle(
              color: AppColores.principal,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _dh.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_dh.swsId} · ${_dh.country}',
            style: const TextStyle(
              color: Color(0xFF888888),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  /// Barra de Estadísticas Rápidas (Carreras, Podios, Puntos dinámicos del historial)
  Widget _buildStatsContainer() {
    return StreamBuilder<List<HistorialCircuito>>(
      stream: HistorialCircuito.obtenerHistorialStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }
        final historial = snapshot.data ?? [];
        int totalPuntos = 0;
        for (var item in historial) {
          final numStr = item.puntos.replaceAll(RegExp(r'[^0-9]'), '');
          totalPuntos += int.tryParse(numStr) ?? 0;
        }
        final puntosFinales = totalPuntos > 0 ? totalPuntos.toString() : _dh.points.toString();
        final carrerasFinales = historial.isNotEmpty ? historial.length.toString() : _dh.races.toString();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          decoration: BoxDecoration(
            color: AppColores.cardOscuro,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: const Color(0xFF2A2A2A)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(carrerasFinales, 'CARRERAS'),
              _buildStatDivider(),
              _buildStatItem(_dh.podiums.toString(), 'PODIOS'),
              _buildStatDivider(),
              _buildStatItem(puntosFinales, 'PUNTOS'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF777777),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 24,
      width: 1,
      color: const Color(0xFF2A2A2A),
    );
  }

  /// Contenedor Principal Blanco con Ranking, Victorias, Carreras y Logros
  Widget _buildMainContentContainer() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFF7F7F7),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.0),
          topRight: Radius.circular(32.0),
        ),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRankingAndVictoriesRow(),
          const SizedBox(height: 24),
          _buildRecentRacesSection(),
          const SizedBox(height: 28),
          _buildAchievementsSection(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// Tarjetas de Ranking Nacional y Victorias (Ranking calculado dinámicamente)
  Widget _buildRankingAndVictoriesRow() {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('Perfiles')
          .orderBy('points', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        int calculatedRank = 1;
        if (snapshot.hasData && currentUid != null) {
          final docs = snapshot.data!.docs;
          for (int i = 0; i < docs.length; i++) {
            if (docs[i].id == currentUid) {
              calculatedRank = i + 1;
              break;
            }
          }
        } else if (_dh.nationalRank > 0) {
          calculatedRank = _dh.nationalRank;
        }

        return Row(
          children: [
            // Ranking Nacional Card (Naranja)
            Expanded(
              flex: 11,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColores.principal,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.bar_chart, color: Colors.white, size: 24),
                    const SizedBox(height: 12),
                    const Text(
                      'RANKING NACIONAL',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '#$calculatedRank',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(50),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _dh.rankChange,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Victorias Card (Blanco)
            Expanded(
              flex: 9,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColores.principal.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.emoji_events_outlined,
                          color: AppColores.principal, size: 20),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _dh.victories.toString(),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'VICTORIAS',
                      style: TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Sección de Últimas Carreras (Dinámica desde Firestore)
  Widget _buildRecentRacesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TEMPORADA 2026',
                  style: TextStyle(
                    color: AppColores.principal,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'CIRCUITOS',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              'Ver todas',
              style: TextStyle(
                color: Color(0xFF777777),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<HistorialCircuito>>(
          stream: HistorialCircuito.obtenerHistorialStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(color: AppColores.principal),
                ),
              );
            }

            if (snapshot.hasError) {
              return Text(
                'Error al cargar historial: ${snapshot.error}',
                style: const TextStyle(color: AppColores.error, fontSize: 13),
              );
            }

            final historial = snapshot.data ?? [];

            if (historial.isEmpty) {
              return const Text(
                'No hay historial de circuitos registrado',
                style: TextStyle(color: Color(0xFF777777), fontSize: 13),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: historial.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = historial[index];
                return _buildRaceItem(
                  position: item.posicion,
                  isPodium: item.isPodium,
                  title: item.nombre,
                  date: item.fecha,
                  points: item.puntos,
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildRaceItem({
    required String position,
    required bool isPodium,
    required String title,
    required String date,
    required String points,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isPodium
                  ? AppColores.principal
                  : const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                position,
                style: TextStyle(
                  color: isPodium ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  date,
                  style: const TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            points,
            style: const TextStyle(
              color: AppColores.principal,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  /// Sección de Colección de Logros
  Widget _buildAchievementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'COLECCIÓN',
                  style: TextStyle(
                    color: AppColores.principal,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Mis logros',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              '6 de 18',
              style: TextStyle(
                color: Color(0xFF777777),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 130,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildAchievementCard(
                icon: Icons.emoji_events,
                iconColor: AppColores.principal,
                bgColor: AppColores.principal.withAlpha(30),
                title: 'Primera victoria',
              ),
              const SizedBox(width: 12),
              _buildAchievementCard(
                icon: Icons.star_border,
                iconColor: Colors.white70,
                bgColor: Colors.white.withAlpha(20),
                title: 'Top 50',
              ),
              const SizedBox(width: 12),
              _buildAchievementCard(
                icon: Icons.flag_outlined,
                iconColor: Colors.white70,
                bgColor: Colors.white.withAlpha(20),
                title: '20 carreras',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
  }) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColores.cardOscuro,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF262626)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
