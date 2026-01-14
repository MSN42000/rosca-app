// lib/models/group_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// ===================================================================
// Member Model (SIMPLIFIÉ)
// ===================================================================

class GroupMember {
  final String userId;
  final String name;
  final String email;
  final int joinOrder;
  final bool hasReceived;
  final String role; // "admin" ou "member"

  GroupMember({
    required this.userId,
    required this.name,
    required this.email,
    required this.joinOrder,
    this.hasReceived = false,
    this.role = 'member',
  });

  factory GroupMember.fromMap(Map<String, dynamic> map) {
    return GroupMember(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      joinOrder: map['joinOrder'] ?? 0,
      hasReceived: map['hasReceived'] ?? false,
      role: map['role'] ?? 'member',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'joinOrder': joinOrder,
      'hasReceived': hasReceived,
      'role': role,
    };
  }

  GroupMember copyWith({
    String? userId,
    String? name,
    String? email,
    int? joinOrder,
    bool? hasReceived,
    String? role,
  }) {
    return GroupMember(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      joinOrder: joinOrder ?? this.joinOrder,
      hasReceived: hasReceived ?? this.hasReceived,
      role: role ?? this.role,
    );
  }
}

// ===================================================================
// Group Model (SIMPLIFIÉ)
// ===================================================================

class GroupModel {
  final String id;
  final String name;
  final double monthlyAmount;
  final int currentRound;
  final int totalRounds;
  final String createdBy;
  final String status; // "active", "completed"
  final List<GroupMember> members;
  final DateTime? createdAt;

  GroupModel({
    required this.id,
    required this.name,
    required this.monthlyAmount,
    this.currentRound = 1,
    required this.totalRounds,
    required this.createdBy,
    this.status = 'active',
    this.members = const [],
    this.createdAt,
  });

  // Depuis Firestore
  factory GroupModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return GroupModel(
      id: doc.id,
      name: data['name'] ?? '',
      monthlyAmount: (data['monthlyAmount'] ?? 0.0).toDouble(),
      currentRound: data['currentRound'] ?? 1,
      totalRounds: data['totalRounds'] ?? 0,
      createdBy: data['createdBy'] ?? '',
      status: data['status'] ?? 'active',
      members: (data['members'] as List<dynamic>?)
          ?.map((m) => GroupMember.fromMap(m as Map<String, dynamic>))
          .toList() ?? [],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Vers Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'monthlyAmount': monthlyAmount,
      'currentRound': currentRound,
      'totalRounds': totalRounds,
      'createdBy': createdBy,
      'status': status,
      'members': members.map((m) => m.toMap()).toList(),
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  // CopyWith
  GroupModel copyWith({
    String? id,
    String? name,
    double? monthlyAmount,
    int? currentRound,
    int? totalRounds,
    String? createdBy,
    String? status,
    List<GroupMember>? members,
    DateTime? createdAt,
  }) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      monthlyAmount: monthlyAmount ?? this.monthlyAmount,
      currentRound: currentRound ?? this.currentRound,
      totalRounds: totalRounds ?? this.totalRounds,
      createdBy: createdBy ?? this.createdBy,
      status: status ?? this.status,
      members: members ?? this.members,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Méthodes utilitaires
  bool isAdmin(String userId) => createdBy == userId;
  int get activeMembersCount => members.length;
  double get totalAmountPerRound => monthlyAmount * activeMembersCount;
  bool get isCompleted => currentRound > totalRounds || status == 'completed';
  bool get isActive => status == 'active';
}