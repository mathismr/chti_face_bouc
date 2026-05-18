import 'package:firebase_auth/firebase_auth.dart';

class ServiceAuthentification {
  final _instance = FirebaseAuth.instance;

  // Connecter a Firebase
  Future<String?> signIn(
      {required String email, required String password}) async {
    String result = "";
    try {
      await _instance.signInWithEmailAndPassword(
          email: email, password: password);
      result = "OK";
    } on FirebaseAuthException catch (e) {
      result = e.message ?? "Erreur inconnue";
    }
    return result;
  }

  // Creer un compte sur Firebase
  Future<String?> createAccount({
    required String email,
    required String password,
    required String surname,
    required String name,
  }) async {
    String result = "";
    try {
      final credential = await _instance.createUserWithEmailAndPassword(
          email: email, password: password);
      result = credential.user?.uid ?? "";
    } on FirebaseAuthException catch (e) {
      result = e.message ?? "Erreur inconnue";
    }
    return result;
  }

  // Deconnecter de Firebase
  Future<bool> signOut() async {
    bool result = false;
    try {
      await _instance.signOut();
      result = true;
    } catch (e) {
      result = false;
    }
    return result;
  }

  // Recuperer l'id unique de l'utilisateur
  String? get myId => _instance.currentUser?.uid;

  // Voir si vous etes l'utilisateur
  bool isMe(String profileId) {
    bool result = false;
    if (_instance.currentUser?.uid == profileId) {
      result = true;
    }
    return result;
  }
}
