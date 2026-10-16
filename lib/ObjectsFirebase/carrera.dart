import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Carrera {
  final String uid;
  final String nombre;
  final String circuito;
  final String fecha;
  final String imagenAsset;

  const Carrera({
    required this.uid,
    required this.nombre,
    required this.circuito,
    required this.fecha,
    this.imagenAsset = 'assets/images/imagen_de_carrera.jpg',
  });

  // Getters para compatibilidad con la interfaz
  String get titulo => nombre;
  String get categoria => 'SWS RACE';
  String get lugar => circuito;
  String get dia => fecha;
  String get mes => '';
  String get plazas => 'SWS OFFICIAL';
  String get imagenUrl => '';

  factory Carrera.fromMap(Map<String, dynamic> map, String docId) {
    return Carrera(
      uid: docId,
      nombre: (map['Nombre'] ?? map['nombre'] ?? map['titulo'] ?? 'Carrera SWS').toString(),
      circuito: (map['Circuito'] ?? map['circuito'] ?? 'Circuito').toString(),
      fecha: (map['Fecha'] ?? map['fecha'] ?? 'Próximamente').toString(),
      imagenAsset: 'assets/images/imagen_de_carrera.jpg',
    );
  }

  Map<String, dynamic> toMap() => {
    'Nombre': nombre,
    'Circuito': circuito,
    'Fecha': fecha,
  };

  // Referencia a la colección 'Carreras' en Firestore con conversión tipada (withConverter)
  static CollectionReference<Carrera> get collectionRef =>
      FirebaseFirestore.instance
          .collection('Carreras')
          .withConverter<Carrera>(
            fromFirestore: (snapshot, _) =>
                Carrera.fromMap(snapshot.data() ?? {}, snapshot.id),
            toFirestore: (carrera, _) => carrera.toMap(),
          );

  // Stream para todas las carreras
  static Stream<List<Carrera>> obtenerCarrerasStream() {
    return collectionRef.snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
        );
  }

  // Comprobar en tiempo real si el usuario actual está inscrito a esta carrera
  static Stream<bool> estaInscritoStream(String carreraUid) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || carreraUid.isEmpty) return Stream.value(false);

    return FirebaseFirestore.instance
        .collection('Perfiles')
        .doc(user.uid)
        .collection('mis_carreras')
        .doc(carreraUid)
        .snapshots()
        .map((doc) => doc.exists);
  }

  // Guardar / eliminar la inscripción en la subcolección 'mis_carreras' del usuario
  static Future<bool> alternarInscripcion(Carrera carrera) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final docRef = FirebaseFirestore.instance
        .collection('Perfiles')
        .doc(user.uid)
        .collection('mis_carreras')
        .doc(carrera.uid.isNotEmpty ? carrera.uid : carrera.nombre.replaceAll(' ', '_'));

    final docSnap = await docRef.get();
    if (docSnap.exists) {
      await docRef.delete();
      return false; // Desinscrito
    } else {
      await docRef.set({
        'Nombre': carrera.nombre,
        'Circuito': carrera.circuito,
        'Fecha': carrera.fecha,
        'fechaInscripcion': FieldValue.serverTimestamp(),
      });
      return true; // Inscrito
    }
  }

  // Stream para obtener las carreras inscritas del usuario actual en tiempo real
  static Stream<List<Carrera>> obtenerMisCarrerasStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    return FirebaseFirestore.instance
        .collection('Perfiles')
        .doc(user.uid)
        .collection('mis_carreras')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Carrera.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Método para añadir una nueva carrera directamente a la colección 'Carreras'
  static Future<void> crearCarrera({
    required String nombre,
    required String circuito,
    required String fecha,
  }) async {
    final nuevaCarrera = Carrera(
      uid: '',
      nombre: nombre,
      circuito: circuito,
      fecha: fecha,
    );
    await collectionRef.add(nuevaCarrera);
  }
}
