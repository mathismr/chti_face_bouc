import 'package:firebase_auth/firebase_auth.dart';

class ServiceAuthentification {
  final _instance = FirebaseAuth.instance;

  static String _errorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return "L'adresse mail n'est pas valide.";
      case 'user-disabled':
        return "Ce compte a été désactivé.";
      case 'user-not-found':
        return "Aucun compte trouvé avec cette adresse mail.";
      case 'wrong-password':
        return "Mot de passe incorrect.";
      case 'invalid-credential':
        return "Adresse mail ou mot de passe incorrect.";
      case 'email-already-in-use':
        return "Un compte existe déjà avec cette adresse mail.";
      case 'weak-password':
        return "Le mot de passe est trop faible (6 caractères minimum).";
      case 'operation-not-allowed':
        return "Cette opération n'est pas autorisée.";
      case 'too-many-requests':
        return "Trop de tentatives. Veuillez réessayer plus tard.";
      case 'network-request-failed':
        return "Erreur réseau. Vérifiez votre connexion internet.";
      default:
        return "Erreur inconnue ($code).";
    }
  }

  // Connecter a Firebase
  Future<String> signIn(
      {required String email, required String password}) async {
    try {
      await _instance.signInWithEmailAndPassword(
          email: email, password: password);
      return "OK";
    } on FirebaseAuthException catch (e) {
      return _errorMessage(e.code);
    }
  }

  // Creer un compte sur Firebase
  Future<String> createAccount({
    required String email,
    required String password,
    required String surname,
    required String name,
  }) async {
    try {
      final credential = await _instance.createUserWithEmailAndPassword(
          email: email, password: password);
      return credential.user?.uid ?? "";
    } on FirebaseAuthException catch (e) {
      return _errorMessage(e.code);
    }
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

  // Supprimer le compte Firebase Auth
  Future<bool> deleteAccount() async {
    try {
      await _instance.currentUser?.delete();
      return true;
    } on FirebaseAuthException {
      return false;
    }
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
