import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Dataholder {
  static final Dataholder _instance = Dataholder._internal();
  factory Dataholder() => _instance;
  Dataholder._internal();

  User? currentUser;
  Map<String, dynamic>? userData;



  String get name => userData?['name'] ?? currentUser?.displayName ?? 'Piloto SWS';
  String get email => userData?['email'] ?? currentUser?.email ?? '';
  String get swsId => userData?['swsId'] ?? 'ES-ITK-${currentUser?.uid.substring(0, 6).toUpperCase() ?? "000000"}';
  String get country => userData?['country'] ?? 'España';
  int get races => (userData?['races'] as num?)?.toInt() ?? 0;
  int get podiums => (userData?['podiums'] as num?)?.toInt() ?? 0;
  int get points => (userData?['points'] as num?)?.toInt() ?? 0;
  int get victories => (userData?['victories'] as num?)?.toInt() ?? 0;
  int get nationalRank => (userData?['nationalRank'] as num?)?.toInt() ?? 0;
  String get rankChange => userData?['rankChange'] ?? '+0 puestos';

  Future<void> loadUserData() async {
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        final docRef = FirebaseFirestore.instance.collection('users').doc(currentUser!.uid);
        final docSnap = await docRef.get();

        if (docSnap.exists && docSnap.data() != null) {
          userData = docSnap.data();
        } else {
          // Default profile for new user
          userData = {
            'name': currentUser!.displayName?.isNotEmpty == true 
                ? currentUser!.displayName 
                : 'Piloto SWS',
            'email': currentUser!.email ?? '',
            'swsId': 'ES-ITK-${currentUser!.uid.substring(0, 6).toUpperCase()}',
            'country': 'España',
            'races': 0,
            'podiums': 0,
            'points': 0,
            'victories': 0,
            'nationalRank': 99,
            'rankChange': '+0 puestos',
            'createdAt': FieldValue.serverTimestamp(),
          };
          await docRef.set(userData!);
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
  }
}
