import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Perfil {
  String? uid;
  String? name;
  int? edad;
  double? altura;
  double? peso;
  String? urlAvatar;
  Image? avatar;

  Perfil({
    this.uid,
    this.name,
    this.edad,
    this.altura,
    this.peso,
    this.urlAvatar,
    this.avatar,
  });

  factory Perfil.fromFirestore(Map<String, dynamic> map, String docId) {
    return Perfil(
      uid: docId,
      name: map['name'] as String?,
      edad: (map['edad'] as num?)?.toInt(),
      altura: (map['altura'] as num?)?.toDouble(),
      peso: (map['peso'] as num?)?.toDouble(),
      urlAvatar: map['urlAvatar'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (name != null) 'name': name,
      if (edad != null) 'edad': edad,
      if (altura != null) 'altura': altura,
      if (peso != null) 'peso': peso,
      if (urlAvatar != null) 'urlAvatar': urlAvatar,
    };
  }

  // Referencia a Firestore con conversión tipada (withConverter)
  static CollectionReference<Perfil> get collectionRef =>
      FirebaseFirestore.instance
          .collection('Perfiles')
          .withConverter<Perfil>(
            fromFirestore: (snapshot, _) =>
                Perfil.fromFirestore(snapshot.data() ?? {}, snapshot.id),
            toFirestore: (perfil, _) => perfil.toFirestore(),
          );
}
