import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistorialCircuito {
  final String uid;
  final String nombre;
  final String posicion;
  final String puntos;
  final String fecha;
  final bool isPodium;

  const HistorialCircuito({
    required this.uid,
    required this.nombre,
    required this.posicion,
    required this.puntos,
    required this.fecha,
    required this.isPodium,
  });

  factory HistorialCircuito.fromMap(Map<String, dynamic> map, String docId) {
    final pos = (map['posicion'] ?? map['Poscion'] ?? 'P1').toString();
    final isPod = (map['isPodium'] ?? (pos == 'P1')) as bool;
    return HistorialCircuito(
      uid: docId,
      nombre: (map['nombre'] ?? map['Nombre'] ?? 'Circuito SWS').toString(),
      posicion: pos,
      puntos: (map['puntos'] ?? map['Puntos'] ?? '+100 pts').toString(),
      fecha: (map['fecha'] ?? map['Fecha'] ?? '01 OCT 2026').toString(),
      isPodium: isPod,
    );
  }

  Map<String, dynamic> toMap() => {
    'nombre': nombre,
    'posicion': posicion,
    'puntos': puntos,
    'fecha': fecha,
    'isPodium': isPodium,
  };

  // Lee exclusivamente desde la subcolección de Firestore 'historial_circuitos'
  static Stream<List<HistorialCircuito>> obtenerHistorialStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    return FirebaseFirestore.instance
        .collection('Perfiles')
        .doc(user.uid)
        .collection('historial_circuitos')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HistorialCircuito.fromMap(doc.data(), doc.id))
            .toList());
  }
}
