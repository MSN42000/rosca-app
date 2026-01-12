
// Import Firestore database package
import 'package:cloud_firestore/cloud_firestore.dart';

// Import user data model
import '../models/user_model.dart';

// DatabaseService centralizes all Firestore operations
// It keeps database logic clean, reusable, and separated from UI
class DatabaseService {

  // Firebase Firestore instance (entry point to the database)
  final FirebaseFirestore _db = FirebaseFirestore.instance;


  // Creates or updates a user profile after authentication
  // This method is usually called right after user signup
  Future<void> createUserProfile({
    required String userId,
    required String name,
    required String email,
    String? phone,
  }) async {
    try {
      // Access "users" collection and create document with userId
      await _db.collection('users').doc(userId).set({
        'name': name,
        'email': email,
        'phone': phone,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Confirm creation
      print('User profile created');
    } catch (e) {
      // Forward error to caller
      print('Error creating user profile');
      rethrow;
    }
  }

  // Fetches a user profile once (non real-time)
  // Returns a UserModel or null if not found
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      // Retrieve user document
      final doc = await _db.collection('users').doc(userId).get();

      // Convert document to model if it exists
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }

      // User not found
      return null;
    } catch (e) {
      print('Error fetching user profile');
      return null;
    }
  }

  // Listens to user profile changes in real time
  // Useful for live UI updates
  Stream<DocumentSnapshot> getUserStream(String userId) {
    return _db.collection('users').doc(userId).snapshots();
  }

  // Updates specific fields of a user profile
  // Unlike set(), update() preserves existing fields
  Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      // Automatically track last update time
      data['updatedAt'] = FieldValue.serverTimestamp();

      // Apply partial update
      await _db.collection('users').doc(userId).update(data);

      print('User profile updated');
    } catch (e) {
      print('Error updating profile');
      rethrow;
    }
  }

  // Deletes a user profile from Firestore
  // Does NOT delete Firebase Authentication account
  Future<void> deleteUserProfile(String userId) async {
    try {
      await _db.collection('users').doc(userId).delete();
      print('User profile deleted');
    } catch (e) {
      print('Error deleting profile');
      rethrow;
    }
  }

  // Searches users by exact name match
  // Firestore does not support partial string search
  Future<List<UserModel>> searchUsersByName(String name) async {
    try {
      final snapshot = await _db
          .collection('users')
          .where('name', isEqualTo: name)
          .get();

      // Convert results into models
      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Search error');
      return [];
    }
  }

  // Retrieves all users (optionally limited)
  // Should be used carefully for large collections
  Future<List<UserModel>> getAllUsers({int? limit}) async {
    try {
      Query query = _db
          .collection('users')
          .orderBy('createdAt', descending: true);

      // Apply limit if provided
      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error loading users');
      return [];
    }
  }

  // Listens to all users in real time
  // Ideal for live lists or admin dashboards
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

  // Atomically increments a numeric field
  // Prevents concurrency issues
  Future<void> incrementField({
    required String collection,
    required String docId,
    required String field,
    int value = 1,
  }) async {
    try {
      await _db.collection(collection).doc(docId).update({
        field: FieldValue.increment(value),
      });
    } catch (e) {
      print('Increment error');
    }
  }

  // Adds a value to an array field if it does not already exist
  Future<void> addToArray({
    required String collection,
    required String docId,
    required String field,
    required dynamic value,
  }) async {
    try {
      await _db.collection(collection).doc(docId).update({
        field: FieldValue.arrayUnion([value]),
      });
    } catch (e) {
      print('Array add error');
    }
  }

  // Removes a value from an array field
  Future<void> removeFromArray({
    required String collection,
    required String docId,
    required String field,
    required dynamic value,
  }) async {
    try {
      await _db.collection(collection).doc(docId).update({
        field: FieldValue.arrayRemove([value]),
      });
    } catch (e) {
      print('Array remove error');
    }
  }
}
