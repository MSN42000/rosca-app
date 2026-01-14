// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Handles authentication and initial user profile creation
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Register a new user and create a Firestore profile
  Future<User?> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      // Create user with email and password
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Create user profile in Firestore
        await _db.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'phone': phone,
          'walletBalance': 0.0,
          'groupIds': [],
          'adminGroupIds': [],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  /// Login an existing user
  Future<User?> login(String email, String password) async {
    try {
      UserCredential userCredential =
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential.user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Currently authenticated user
  User? get currentUser => _auth.currentUser;

  /// Listen to authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if a user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Delete current user account
  /// Firestore user document must be deleted separately
  Future<void> deleteAccount() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.delete();
    }
  }
}
