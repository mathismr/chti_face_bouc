import 'package:cloud_firestore/cloud_firestore.dart';

import 'constantes.dart';

class Membre {
  DocumentReference reference;
  String id;
  Map<String, dynamic> map;

  Membre({required this.reference, required this.id, required this.map});

  String get name => map[nameKey] ?? "";
  String get surname => map[surnameKey] ?? "";
  String get profilePicture => map[profilePictureKey] ?? "";
  String get coverPicture => map[coverPictureKey] ?? "";
  String get description => map[descriptionKey] ?? "";
  String get fullName => "$surname $name";
}
