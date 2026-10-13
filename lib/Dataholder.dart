import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'ObjectsFirebase/Perfil.dart';

class StorageAdmin {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> subirAvatar(XFile fichero) async {
    try {
      final bytes = await fichero.readAsBytes();
      if (bytes.isEmpty) return null;

      final fileName = 'avatars/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(fileName);

      // Set timeout to prevent hanging indefinitely on Web/Storage rules issue
      await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      ).timeout(const Duration(seconds: 10));

      return await ref.getDownloadURL();
    } catch (e) {
      // Return null on storage failure or timeout
      return null;
    }
  }
}

class Dataholder {
  static final Dataholder _instance = Dataholder._internal();
  factory Dataholder() => _instance;
  static Dataholder get instance => _instance;
  Dataholder._internal();

  User? currentUser;
  Map<String, dynamic>? userData;
  Perfil perfilUsuario = Perfil();
  StorageAdmin storageadmin = StorageAdmin();

  // Convenience getters for user profile
  String get name => perfilUsuario.name ?? userData?['name'] ?? currentUser?.displayName ?? 'Piloto SWS';
  String get email => userData?['email'] ?? currentUser?.email ?? '';
  String get swsId => userData?['swsId'] ?? 'ES-ITK-${currentUser?.uid.substring(0, 6).toUpperCase() ?? "000000"}';
  String get country => userData?['country'] ?? 'España';
  String? get urlAvatar => perfilUsuario.urlAvatar ?? userData?['urlAvatar'];
  int get races => (userData?['races'] as num?)?.toInt() ?? 0;
  int get podiums => (userData?['podiums'] as num?)?.toInt() ?? 0;
  int get points => (userData?['points'] as num?)?.toInt() ?? 0;
  int get victories => (userData?['victories'] as num?)?.toInt() ?? 0;
  int get nationalRank => (userData?['nationalRank'] as num?)?.toInt() ?? 0;
  String get rankChange => userData?['rankChange'] ?? '+0 puestos';

  // Load user data from Firestore or initialize default if document doesn't exist
  Future<void> loadUserData() async {
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        final docRef = FirebaseFirestore.instance.collection('Perfiles').doc(currentUser!.uid);
        final docSnap = await docRef.get();

        if (docSnap.exists && docSnap.data() != null) {
          userData = docSnap.data();
          perfilUsuario = Perfil.fromFirestore(userData!, currentUser!.uid);
        } else {
          // Default profile for new user
          userData = {
            'name': currentUser!.displayName?.isNotEmpty == true 
                ? currentUser!.displayName 
                : 'Piloto SWS',
            'email': currentUser!.email ?? '',
            'swsId': 'ES-ITK-${currentUser!.uid.substring(0, 6).toUpperCase()}',
            'country': 'España',
            'edad': 25,
            'altura': 1.75,
            'peso': 70.0,
            'races': 0,
            'podiums': 0,
            'points': 0,
            'victories': 0,
            'nationalRank': 99,
            'rankChange': '+0 puestos',
            'createdAt': FieldValue.serverTimestamp(),
          };
          await docRef.set(userData!);
          perfilUsuario = Perfil.fromFirestore(userData!, currentUser!.uid);
        }
      } catch (e) {
        // Fallback in case of network issue
      }
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    currentUser = null;
    userData = null;
    perfilUsuario = Perfil();
  }
}
