// lib/services/database_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Centralizes all Firestore operations related to users
class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // =====================================================
  // USER PROFILE
  // =====================================================

  /// Create or update a user profile (merge prevents overwrite)
  Future<void> createUserProfile({
    required String userId,
    required String name,
    required String email,
    String? phone,
  }) async {
    await _db.collection('users').doc(userId).set({
      'name': name,
      'email': email,
      'phone': phone,
      'walletBalance': 0.0,
      'groupIds': [],
      'adminGroupIds': [],
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Get user profile once
  Future<UserModel?> getUserProfile(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();

    if (doc.exists && doc.data() != null) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  /// Listen to user profile changes in real time
  Stream<UserModel?> getUserProfileStream(String userId) {
    return _db.collection('users').doc(userId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    });
  }

  /// Update selected fields of the user profile
  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? email,
    String? phone,
  }) async {
    final Map<String, dynamic> updates = {};

    if (name != null) updates['name'] = name;
    if (email != null) updates['email'] = email;
    if (phone != null) updates['phone'] = phone;

    if (updates.isNotEmpty) {
      await _db.collection('users').doc(userId).update(updates);
    }
  }

  /// Delete user profile
  Future<void> deleteUserProfile(String userId) async {
    await _db.collection('users').doc(userId).delete();
  }

  // =====================================================
  // WALLET
  // =====================================================

  /// Set wallet balance
  Future<void> updateWalletBalance({
    required String userId,
    required double newBalance,
  }) async {
    await _db.collection('users').doc(userId).update({
      'walletBalance': newBalance,
    });
  }

  /// Add amount to wallet (atomic)
  Future<void> addToWallet({
    required String userId,
    required double amount,
  }) async {
    await _db.collection('users').doc(userId).update({
      'walletBalance': FieldValue.increment(amount),
    });
  }

  /// Deduct amount from wallet (atomic)
  Future<void> deductFromWallet({
    required String userId,
    required double amount,
  }) async {
    await _db.collection('users').doc(userId).update({
      'walletBalance': FieldValue.increment(-amount),
    });
  }

  /// Get wallet balance only
  Future<double> getWalletBalance(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists) {
      return (doc.data()?['walletBalance'] ?? 0.0).toDouble();
    }
    return 0.0;
  }

  // =====================================================
  // GROUP MANAGEMENT
  // =====================================================

  /// Add user to a group
  Future<void> addUserToGroup({
    required String userId,
    required String groupId,
  }) async {
    await _db.collection('users').doc(userId).update({
      'groupIds': FieldValue.arrayUnion([groupId]),
    });
  }

  /// Remove user from a group
  Future<void> removeUserFromGroup({
    required String userId,
    required String groupId,
  }) async {
    await _db.collection('users').doc(userId).update({
      'groupIds': FieldValue.arrayRemove([groupId]),
    });
  }

  /// Set user as group admin
  Future<void> addUserAsGroupAdmin({
    required String userId,
    required String groupId,
  }) async {
    await _db.collection('users').doc(userId).update({
      'adminGroupIds': FieldValue.arrayUnion([groupId]),
    });
  }

  /// Remove admin rights from a group
  Future<void> removeUserAsGroupAdmin({
    required String userId,
    required String groupId,
  }) async {
    await _db.collection('users').doc(userId).update({
      'adminGroupIds': FieldValue.arrayRemove([groupId]),
    });
  }

  /// Get all groups of a user
  Future<List<String>> getUserGroups(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists) {
      return List<String>.from(doc.data()?['groupIds'] ?? []);
    }
    return [];
  }

  /// Get all admin groups of a user
  Future<List<String>> getUserAdminGroups(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists) {
      return List<String>.from(doc.data()?['adminGroupIds'] ?? []);
    }
    return [];
  }

  // =====================================================
  // USER SEARCH & LISTING
  // =====================================================

  /// Search users by exact name
  Future<List<UserModel>> searchUsersByName(String name) async {
    final snapshot = await _db
        .collection('users')
        .where('name', isEqualTo: name)
        .get();

    return snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc))
        .toList();
  }

  /// Search user by email
  Future<UserModel?> searchUserByEmail(String email) async {
    final snapshot = await _db
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return UserModel.fromFirestore(snapshot.docs.first);
    }
    return null;
  }

  /// Get all users (optional limit)
  Future<List<UserModel>> getAllUsers({int? limit}) async {
    Query query = _db
        .collection('users')
        .orderBy('createdAt', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc))
        .toList();
  }

  /// Listen to all users in real time
  Stream<List<UserModel>> getAllUsersStream({int? limit}) {
    Query query = _db
        .collection('users')
        .orderBy('createdAt', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map(
          (snapshot) => snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList(),
    );
  }

  /// Get users by their document IDs (Firestore limit: 10)
  Future<List<UserModel>> getUsersByIds(List<String> userIds) async {
    if (userIds.isEmpty) return [];

    List<UserModel> users = [];

    for (int i = 0; i < userIds.length; i += 10) {
      final batch = userIds.skip(i).take(10).toList();
      final snapshot = await _db
          .collection('users')
          .where(FieldPath.documentId, whereIn: batch)
          .get();

      users.addAll(
        snapshot.docs.map((doc) => UserModel.fromFirestore(doc)),
      );
    }

    return users;
  }

  // =====================================================
  // GENERIC UTILITIES
  // =====================================================

  /// Atomically increment a numeric field
  Future<void> incrementField({
    required String userId,
    required String field,
    num value = 1,
  }) async {
    await _db.collection('users').doc(userId).update({
      field: FieldValue.increment(value),
    });
  }

  /// Check if a user exists
  Future<bool> userExists(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.exists;
  }

  /// Get total number of users
  Future<int> getTotalUsersCount() async {
    final snapshot = await _db.collection('users').count().get();
    return snapshot.count ?? 0;
  }
}
