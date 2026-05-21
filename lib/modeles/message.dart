import 'package:cloud_firestore/cloud_firestore.dart';
import 'constantes.dart';

class Message {
  DocumentReference reference;
  String id;
  Map<String, dynamic> map;

  Message({required this.reference, required this.id, required this.map});

  String get senderId => map[senderIdKey] ?? "";
  String get text => map[textKey] ?? "";
  String get gifUrl => map[gifUrlKey] ?? "";
  int get date => map[dateKey] ?? 0;
}
