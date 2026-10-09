import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_view.dart';

class PerfilView extends StatefulWidget {
  const PerfilView({super.key});

  @override
  State<PerfilView> createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  @override
  void initState() {
    super.initState();
    _ensureUserDocumentExists();
  }

  Future<void> _ensureUserDocumentExists() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final docRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
    final docSnap = await docRef.get();

    if (!docSnap.exists) {
      // Initialize default user stats in Firestore collection
      await docRef.set({
        'name': currentUser.displayName ?? 'Andrew Paredes',
        'email': currentUser.email ?? '',
        'swsId': 'ES-ITK-${currentUser.uid.substring(0, 6).toUpperCase()}',
        'country': 'España',
        'races': 24,
        'podiums': 7,
        'points': 1284,
        'victories': 3,
        'nationalRank': 38,
        'rankChange': '+6 puestos',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFE54622);
    const darkBackground = Color(0xFF111111);
    const cardDark = Color(0xFF1B1B1B);

    final currentUser = FirebaseAuth.instance.currentUser;
    final uid = currentUser?.uid ?? 'default_user';

    return Scaffold(
      backgroundColor: darkBackground,
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .snapshots(),
          builder: (context, snapshot) {
            // Default fallback values if loading
            String name = currentUser?.displayName ?? 'Andrew Paredes';
            String swsId = 'ES-ITK-161726';
            String country = 'España';
            int races = 24;
            int podiums = 7;
            int points = 1284;
            int victories = 3;
            int nationalRank = 38;
            String rankChange = '+6 puestos';

            if (snapshot.hasData && snapshot.data!.exists) {
              final data = snapshot.data!.data();
              if (data != null) {
                name = data['name'] ?? name;
                swsId = data['swsId'] ?? swsId;
                country = data['country'] ?? country;
                races = data['races'] ?? races;
                podiums = data['podiums'] ?? podiums;
                points = data['points'] ?? points;
                victories = data['victories'] ?? victories;
                nationalRank = data['nationalRank'] ?? nationalRank;
                rankChange = data['rankChange'] ?? rankChange;
              }
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar with Logout & Edit Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.logout,
                              color: Colors.redAccent),
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            if (!context.mounted) return;
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginView()),
                            );
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
                            icon: const Icon(Icons.edit,
                                color: Colors.white, size: 18),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Profile Header Info
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: primaryOrange, width: 3),
                              ),
                              child: const CircleAvatar(
                                radius: 48,
                                backgroundImage: NetworkImage(
                                  'https://images.unsplash.com/photo-1568602471122-7832951cc4c5?auto=format&fit=crop&q=80&w=200',
                                ),
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
                                  border: Border.all(
                                      color: darkBackground, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'PILOTO SWS',
                          style: TextStyle(
                            color: primaryOrange,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$swsId · $country',
                          style: const TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Stats Bar Container (Carreras, Podios, Puntos)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    decoration: BoxDecoration(
                      color: cardDark,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(color: const Color(0xFF2A2A2A)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem(races.toString(), 'CARRERAS'),
                        _buildStatDivider(),
                        _buildStatItem(podiums.toString(), 'PODIOS'),
                        _buildStatDivider(),
                        _buildStatItem(points.toString(), 'PUNTOS'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Bottom White Rounded Container for Cards & Lists
                  Container(
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
                        // Ranking and Victories Grid / Row
                        Row(
                          children: [
                            // Ranking Nacional Card (Orange)
                            Expanded(
                              flex: 11,
                              child: Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: primaryOrange,
                                  borderRadius:
                                      BorderRadius.circular(20.0),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.bar_chart,
                                        color: Colors.white, size: 24),
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
                                          '#$nationalRank',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white
                                                .withAlpha(50),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            rankChange,
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
                            // Victorias Card (White)
                            Expanded(
                              flex: 9,
                              child: Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(20.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(5),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color:
                                            primaryOrange.withAlpha(20),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                          Icons.emoji_events_outlined,
                                          color: primaryOrange,
                                          size: 20),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      victories.toString(),
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
                        ),

                        const SizedBox(height: 24),

                        // Últimas carreras Header
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'TEMPORADA 2026',
                                  style: TextStyle(
                                    color: primaryOrange,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Últimas carreras',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Text(
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

                        // Race Items List
                        _buildRaceItem(
                          position: 'P2',
                          isPodium: false,
                          title: 'Karting Campillos',
                          date: '06 OCT 2026',
                          points: '+142 pts',
                        ),
                        const SizedBox(height: 12),
                        _buildRaceItem(
                          position: 'P5',
                          isPodium: false,
                          title: 'Circuito de Madrid',
                          date: '21 SEP 2026',
                          points: '+96 pts',
                        ),
                        const SizedBox(height: 12),
                        _buildRaceItem(
                          position: 'P1',
                          isPodium: true,
                          title: 'Karting Sevilla',
                          date: '07 SEP 2026',
                          points: '+180 pts',
                        ),

                        const SizedBox(height: 28),

                        // Colección / Mis logros Header
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'COLECCIÓN',
                                  style: TextStyle(
                                    color: primaryOrange,
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
                            const Text(
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

                        // Achievements Horizontal Row / Cards
                        SizedBox(
                          height: 130,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _buildAchievementCard(
                                icon: Icons.emoji_events,
                                iconColor: primaryOrange,
                                bgColor: primaryOrange.withAlpha(30),
                                title: 'Primera victoria',
                                isDark: true,
                              ),
                              const SizedBox(width: 12),
                              _buildAchievementCard(
                                icon: Icons.star_border,
                                iconColor: Colors.white70,
                                bgColor: Colors.white.withAlpha(20),
                                title: 'Top 50',
                                isDark: true,
                              ),
                              const SizedBox(width: 12),
                              _buildAchievementCard(
                                icon: Icons.flag_outlined,
                                iconColor: Colors.white70,
                                bgColor: Colors.white.withAlpha(20),
                                title: '20 carreras',
                                isDark: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
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
                  ? const Color(0xFFE54622)
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
              color: Color(0xFFE54622),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required bool isDark,
  }) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: const Color(0xFF262626)) : null,
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
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
