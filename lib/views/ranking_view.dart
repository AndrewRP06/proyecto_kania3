import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RankingView extends StatelessWidget {
  const RankingView({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFE54622);
    const darkBackground = Color(0xFF111111);
    const cardDark = Color(0xFF1B1B1B);

    return Scaffold(
      backgroundColor: darkBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'CLASIFICACIÓN',
                        style: TextStyle(
                          color: primaryOrange,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Ranking Global SWS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF262626),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: primaryOrange,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),

            // Leaderboard List from Firestore
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .orderBy('points', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: primaryOrange),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error al cargar el ranking: ${snapshot.error}',
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.leaderboard, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No hay pilotos registrados aún',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data();
                      final name = data['name'] ?? 'Piloto SWS';
                      final swsId = data['swsId'] ?? 'ES-ITK-000000';
                      final points = data['points'] ?? 0;
                      final rank = index + 1;

                      Color rankColor = const Color(0xFF2A2A2A);
                      Color textColor = Colors.white;

                      if (rank == 1) {
                        rankColor = const Color(0xFFFFD700); // Gold
                        textColor = Colors.black;
                      } else if (rank == 2) {
                        rankColor = const Color(0xFFC0C0C0); // Silver
                        textColor = Colors.black;
                      } else if (rank == 3) {
                        rankColor = const Color(0xFFCD7F32); // Bronze
                        textColor = Colors.white;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: cardDark,
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: rank <= 3
                                ? rankColor.withAlpha(150)
                                : const Color(0xFF2A2A2A),
                            width: rank <= 3 ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Position Badge
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: rankColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '#$rank',
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Pilot Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    swsId,
                                    style: const TextStyle(
                                      color: Color(0xFF888888),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Points
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '$points',
                                  style: const TextStyle(
                                    color: primaryOrange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'PUNTOS',
                                  style: TextStyle(
                                    color: Color(0xFF777777),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
