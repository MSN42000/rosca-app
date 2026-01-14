// lib/models/group_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// ===================================================================
// Member Model (Sous-modèle pour les membres du groupe)
// ===================================================================

class GroupMember {
  final String userId;
  final String name;
  final String email;
  final int joinOrder;
  final bool hasReceived;
  final String role; // "admin" ou "member"
  final String status; // "active", "inactive", "pending"
  final DateTime? joinedAt;

  GroupMember({
    required this.userId,
    required this.name,
    required this.email,
    required this.joinOrder,
    this.hasReceived = false,
    this.role = 'member',
    this.status = 'active',
    this.joinedAt,
  });

  // Depuis Map
  factory GroupMember.fromMap(Map<String, dynamic> map) {
    return GroupMember(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      joinOrder: map['joinOrder'] ?? 0,
      hasReceived: map['hasReceived'] ?? false,
      role: map['role'] ?? 'member',
      status: map['status'] ?? 'active',
      joinedAt: map['joinedAt'] != null
          ? (map['joinedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Vers Map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'joinOrder': joinOrder,
      'hasReceived': hasReceived,
      'role': role,
      'status': status,
      'joinedAt': joinedAt != null
          ? Timestamp.fromDate(joinedAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  GroupMember copyWith({
    String? userId,
    String? name,
    String? email,
    int? joinOrder,
    bool? hasReceived,
    String? role,
    String? status,
    DateTime? joinedAt,
  }) {
    return GroupMember(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      joinOrder: joinOrder ?? this.joinOrder,
      hasReceived: hasReceived ?? this.hasReceived,
      role: role ?? this.role,
      status: status ?? this.status,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}

// ===================================================================
// Group Model
// ===================================================================

class GroupModel {
  final String id;
  final String name;
  final double monthlyAmount;
  final int currentRound;
  final int totalRounds;
  final String? currentReceiverId;
  final List<String> adminIds;
  final String createdBy;
  final String status; // "active", "completed", "cancelled"
  final List<GroupMember> members;
  final DateTime? createdAt;

  GroupModel({
    required this.id,
    required this.name,
    required this.monthlyAmount,
    this.currentRound = 1,
    required this.totalRounds,
    this.currentReceiverId,
    this.adminIds = const [],
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
      currentReceiverId: data['currentReceiverId'],
      adminIds: List<String>.from(data['adminIds'] ?? []),
      createdBy: data['createdBy'] ?? '',
      status: data['status'] ?? 'active',
      members: (data['members'] as List<dynamic>?)
          ?.map((m) => GroupMember.fromMap(m as Map<String, dynamic>))
          .toList() ??
          [],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Depuis Map
  factory GroupModel.fromMap(Map<String, dynamic> map, String id) {
    return GroupModel(
      id: id,
      name: map['name'] ?? '',
      monthlyAmount: (map['monthlyAmount'] ?? 0.0).toDouble(),
      currentRound: map['currentRound'] ?? 1,
      totalRounds: map['totalRounds'] ?? 0,
      currentReceiverId: map['currentReceiverId'],
      adminIds: List<String>.from(map['adminIds'] ?? []),
      createdBy: map['createdBy'] ?? '',
      status: map['status'] ?? 'active',
      members: (map['members'] as List<dynamic>?)
          ?.map((m) => GroupMember.fromMap(m as Map<String, dynamic>))
          .toList() ??
          [],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Vers Map (Create)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'monthlyAmount': monthlyAmount,
      'currentRound': currentRound,
      'totalRounds': totalRounds,
      'currentReceiverId': currentReceiverId,
      'adminIds': adminIds,
      'createdBy': createdBy,
      'status': status,
      'members': members.map((m) => m.toMap()).toList(),
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  // Vers Map (Update)
  Map<String, dynamic> toUpdateMap() {
    return {
      'name': name,
      'monthlyAmount': monthlyAmount,
      'currentRound': currentRound,
      'totalRounds': totalRounds,
      'currentReceiverId': currentReceiverId,
      'adminIds': adminIds,
      'status': status,
      'members': members.map((m) => m.toMap()).toList(),
    };
  }

  // CopyWith
  GroupModel copyWith({
    String? id,
    String? name,
    double? monthlyAmount,
    int? currentRound,
    int? totalRounds,
    String? currentReceiverId,
    List<String>? adminIds,
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
      currentReceiverId: currentReceiverId ?? this.currentReceiverId,
      adminIds: adminIds ?? this.adminIds,
      createdBy: createdBy ?? this.createdBy,
      status: status ?? this.status,
      members: members ?? this.members,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Méthodes utilitaires
  bool isAdmin(String userId) => adminIds.contains(userId);
  bool isMember(String userId) =>
      members.any((m) => m.userId == userId && m.status == 'active');
  int get activeMembersCount =>
      members.where((m) => m.status == 'active').length;
  double get totalAmountPerRound => monthlyAmount * activeMembersCount;
  bool get isCompleted => currentRound > totalRounds || status == 'completed';
  bool get isActive => status == 'active';

  @override
  String toString() {
    return 'GroupModel(id: $id, name: $name, members: ${members.length}, status: $status)';
  }
}