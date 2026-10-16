import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Circuito {
  final String uid;
  final String nombre;
  final String lugar;
  final String longitud;
  final String record;

  const Circuito({
    required this.uid,
    required this.nombre,
    required this.lugar,
    this.longitud = '',
    this.record = '',
  });


  String get imagenLocal {
    final clean = nombre.toLowerCase().replaceAll(' ', '_');
    if (clean.contains('santos')) {
      return 'assets/images/karting_losSantos.png';
    }
    if (clean.contains('hena') || clean.contains('hene')) {
      return 'assets/images/karting_henakart.png';
    }
    if (clean.contains('cabanilla')) {
      return 'assets/images/karting_cabanillas.png';
    }
    return 'assets/images/$clean.png';
  }

  factory Circuito.fromMap(Map<String, dynamic> map, String docId) {
    return Circuito(
      uid: docId,
      nombre: (map['Nombre'] ?? '').toString(),
      lugar: (map['Lugar:'] ?? map['Lugar'] ?? '').toString(),
      longitud: (map['Distancia'] ?? '').toString(),
      record: (map['Record de pista'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() => {
    'Nombre': nombre,
    'Lugar': lugar,
    'Distancia': longitud,
    'Record de pista': double.tryParse(record) ?? 0,
  };


  static CollectionReference<Circuito> get collectionRef =>
      FirebaseFirestore.instance
          .collection('circuitos')
          .withConverter<Circuito>(
            fromFirestore: (snapshot, _) =>
                Circuito.fromMap(snapshot.data() ?? {}, snapshot.id),
            toFirestore: (circuito, _) => circuito.toMap(),
          );

  static Future<List<Circuito>> obtenerCircuitosFirestore() async {
    try {
      final snapshot = await collectionRef.get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error cargando circuitos: $e');
      }
      return [];
    }
  }
}