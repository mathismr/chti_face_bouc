import 'package:cloud_firestore/cloud_firestore.dart';
import 'constantes.dart';

class Post {
  DocumentReference reference;
  String id;
  Map<String, dynamic> map;

  Post({required this.reference, required this.id, required this.map});

  String get member => map[memberIdKey] ?? "";
  String get text => map[textKey] ?? "";
  String get imageUrl => map[postImageKey] ?? "";
  int get date => map[dateKey] ?? 0;
  List<dynamic> get likes => map[likesKey] ?? [];
}
