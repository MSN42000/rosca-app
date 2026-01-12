// lib/models/user_model.dart

// ===================================================================
// Imports
// ===================================================================

// Firestore is used to persist and retrieve user data
import 'package:cloud_firestore/cloud_firestore.dart';

// ===================================================================
// User Model
// ===================================================================

/// UserModel represents an application user.
///
/// It defines the structure of user data and provides
/// methods to convert between Firebase documents and Dart objects.
class UserModel {

  // -------------------------------------------------------------------
  // Properties
  // -------------------------------------------------------------------

  /// Unique identifier of the user.
  /// This value corresponds to the Firebase Authentication UID.
  /// It must remain immutable.
  final String id;

  /// Full name of the user.
  final String name;

  /// Email address associated with the account.
  final String email;

  /// Optional phone number.
  final String? phone;

  /// Optional profile picture URL.
  final String? photoUrl;

  /// Date when the account was created.
  final DateTime? createdAt;

  /// Date of the last profile update.
  final DateTime? updatedAt;

  /// Current account status.
  /// Possible values: active, suspended, deleted.
  final String status;

  // -------------------------------------------------------------------
  // Constructor
  // -------------------------------------------------------------------

  /// Creates a new instance of UserModel.
  ///
  /// Required fields ensure data consistency,
  /// while optional fields allow flexibility.
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.photoUrl,
    this.createdAt,
    this.updatedAt,
    this.status = 'active',
  });

  // -------------------------------------------------------------------
  // Firestore → UserModel
  // -------------------------------------------------------------------

  /// Builds a UserModel instance from a Firestore DocumentSnapshot.
  ///
  /// This constructor is used when reading user data directly
  /// from the Firestore database.
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data =
    doc.data() as Map<String, dynamic>;

    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      photoUrl: data['photoUrl'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      status: data['status'] ?? 'active',
    );
  }

  // -------------------------------------------------------------------
  // Map → UserModel
  // -------------------------------------------------------------------

  /// Builds a UserModel instance from a generic Map.
  ///
  /// This is useful when data comes from an API,
  /// local cache, or other non-Firestore sources.
  factory UserModel.fromMap(
      Map<String, dynamic> map,
      String id,
      ) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      photoUrl: map['photoUrl'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      status: map['status'] ?? 'active',
    );
  }

  // -------------------------------------------------------------------
  // UserModel → Map (Create)
  // -------------------------------------------------------------------

  /// Converts the UserModel into a Map for Firestore creation.
  ///
  /// The user ID is excluded because it is used
  /// as the document identifier in Firestore.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'status': status,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // -------------------------------------------------------------------
  // UserModel → Map (Update)
  // -------------------------------------------------------------------

  /// Converts the UserModel into a Map for updating an existing document.
  ///
  /// The creation date is intentionally preserved.
  Map<String, dynamic> toUpdateMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // -------------------------------------------------------------------
  // Copy with modifications
  // -------------------------------------------------------------------

  /// Creates a new UserModel instance by copying the current one
  /// and applying only the provided changes.
  ///
  /// This approach keeps the model immutable.
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }

  // -------------------------------------------------------------------
  // Business logic helpers
  // -------------------------------------------------------------------

  /// Indicates whether the user profile contains all required information.
  bool isProfileComplete() {
    return name.isNotEmpty &&
        email.isNotEmpty &&
        phone != null &&
        phone!.isNotEmpty;
  }

  /// Returns true if the account is active.
  bool isActive() => status == 'active';

  /// Returns true if the account is suspended.
  bool isSuspended() => status == 'suspended';

  /// Returns the initials of the user's name.
  ///
  /// This is commonly used for avatars.
  String getInitials() {
    if (name.isEmpty) return '?';

    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  // -------------------------------------------------------------------
  // Debug and equality
  // -------------------------------------------------------------------

  /// Returns a readable string representation of the object.
  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email)';
  }

  /// Compares two UserModel instances by value rather than by reference.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.phone == phone &&
        other.status == status;
  }

  /// Generates a hash code consistent with the equality operator.
  @override
  int get hashCode {
    return id.hashCode ^
    name.hashCode ^
    email.hashCode ^
    (phone?.hashCode ?? 0) ^
    status.hashCode;
  }
}
