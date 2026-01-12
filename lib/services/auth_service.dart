import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // S'enregistrer avec email et mot de passe
  Future<User?> register(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return userCredential.user;
    } catch (e) {
      print('Erreur registration: $e');
      return null;
    }
  }

  // Se connecter avec email et mot de passe
  Future<User?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential.user;
    } catch (e) {
      print('Erreur login: $e');
      return null;
    }
  }

  // Déconnexion
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Vérifier si un utilisateur est connecté
  User? get currentUser => _auth.currentUser;
}
