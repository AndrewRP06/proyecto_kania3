import 'dart:async';
import 'package:flutter/foundation.dart';
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
      await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      ).timeout(const Duration(seconds: 8));

      return await ref.getDownloadURL().timeout(const Duration(seconds: 8));
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
  String get name => perfilUsuario.name ?? userData?['name'] ?? currentUser?.displayName ?? 'Piloto';
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
        final docRef = Perfil.collectionRef.doc(currentUser!.uid);
        final docSnap = await docRef.get().timeout(const Duration(seconds: 8));

        if (docSnap.exists && docSnap.data() != null) {
          perfilUsuario = docSnap.data()!;
          userData = perfilUsuario.toFirestore();
        } else {
          // Default profile for new user
          perfilUsuario = Perfil(
            uid: currentUser!.uid,
            name: currentUser!.displayName?.isNotEmpty == true 
                ? currentUser!.displayName 
                : 'Piloto',
            edad: 25,
            altura: 1.75,
            peso: 70.0,
          );
          userData = {
            ...perfilUsuario.toFirestore(),
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
          await FirebaseFirestore.instance
              .collection('Perfiles')
              .doc(currentUser!.uid)
              .set(userData!)
              .timeout(const Duration(seconds: 8));
        }

        // Sincronizar y sumar puntos automáticamente desde el historial en Firestore
        await actualizarPuntosUsuario();
      } catch (e) {
        // Fallback in case of network issue
      }
    }
  }

  Future<void> actualizarPuntosUsuario() async {
    if (currentUser == null) return;
    try {
      final historialSnap = await FirebaseFirestore.instance
          .collection('Perfiles')
          .doc(currentUser!.uid)
          .collection('historial_circuitos')
          .get()
          .timeout(const Duration(seconds: 8));

      int totalPuntos = 0;
      int totalCarreras = historialSnap.docs.length;
      int totalPodios = 0;

      for (var doc in historialSnap.docs) {
        final data = doc.data();
        final puntosStr = (data['puntos'] ?? '+0 pts').toString();
        final numStr = puntosStr.replaceAll(RegExp(r'[^0-9]'), '');
        totalPuntos += int.tryParse(numStr) ?? 0;

        final pos = (data['posicion'] ?? '').toString();
        if (pos == 'P1' || pos == 'P2' || pos == 'P3') {
          totalPodios++;
        }
      }

      await FirebaseFirestore.instance
          .collection('Perfiles')
          .doc(currentUser!.uid)
          .update({
            'points': totalPuntos,
            'races': totalCarreras,
            'podiums': totalPodios,
          })
          .timeout(const Duration(seconds: 8));

      // Recargar datos locales del usuario
      final docSnap = await Perfil.collectionRef.doc(currentUser!.uid).get();
      if (docSnap.exists && docSnap.data() != null) {
        perfilUsuario = docSnap.data()!;
        userData = perfilUsuario.toFirestore();
        userData?['points'] = totalPuntos;
        userData?['races'] = totalCarreras;
        userData?['podiums'] = totalPodios;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error actualizando puntos: $e');
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
