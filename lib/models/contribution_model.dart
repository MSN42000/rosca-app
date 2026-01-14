// lib/models/contribution_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// ===================================================================
// Contribution Model
// ===================================================================

class ContributionModel {
  final String id;
  final String userId;
  final String groupId;
  final String groupName;
  final double amount;
  final int roundNumber;
  final String status; // "pending", "paid", "approved", "rejected"
  final DateTime? paidAt;
  final DateTime? dueDate;
  final String? approvedBy;
  final DateTime? approvedAt;

  ContributionModel({
    required this.id,
    required this.userId,
    required this.groupId,
    required this.groupName,
    required this.amount,
    required this.roundNumber,
    this.status = 'pending',
    this.paidAt,
    this.dueDate,
    this.approvedBy,
    this.approvedAt,
  });

  // Depuis Firestore
  factory ContributionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ContributionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      groupId: data['groupId'] ?? '',
      groupName: data['groupName'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      roundNumber: data['roundNumber'] ?? 0,
      status: data['status'] ?? 'pending',
      paidAt: data['paidAt'] != null
          ? (data['paidAt'] as Timestamp).toDate()
          : null,
      dueDate: data['dueDate'] != null
          ? (data['dueDate'] as Timestamp).toDate()
          : null,
      approvedBy: data['approvedBy'],
      approvedAt: data['approvedAt'] != null
          ? (data['approvedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Depuis Map
  factory ContributionModel.fromMap(Map<String, dynamic> map, String id) {
    return ContributionModel(
      id: id,
      userId: map['userId'] ?? '',
      groupId: map['groupId'] ?? '',
      groupName: map['groupName'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      roundNumber: map['roundNumber'] ?? 0,
      status: map['status'] ?? 'pending',
      paidAt: map['paidAt'] != null
          ? (map['paidAt'] as Timestamp).toDate()
          : null,
      dueDate: map['dueDate'] != null
          ? (map['dueDate'] as Timestamp).toDate()
          : null,
      approvedBy: map['approvedBy'],
      approvedAt: map['approvedAt'] != null
          ? (map['approvedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Vers Map (Create)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'groupId': groupId,
      'groupName': groupName,
      'amount': amount,
      'roundNumber': roundNumber,
      'status': status,
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'approvedBy': approvedBy,
      'approvedAt':
      approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
    };
  }

  // Vers Map (Update)
  Map<String, dynamic> toUpdateMap() {
    return {
      'status': status,
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
      'approvedBy': approvedBy,
      'approvedAt':
      approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
    };
  }

  // CopyWith
  ContributionModel copyWith({
    String? id,
    String? userId,
    String? groupId,
    String? groupName,
    double? amount,
    int? roundNumber,
    String? status,
    DateTime? paidAt,
    DateTime? dueDate,
    String? approvedBy,
    DateTime? approvedAt,
  }) {
    return ContributionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      amount: amount ?? this.amount,
      roundNumber: roundNumber ?? this.roundNumber,
      status: status ?? this.status,
      paidAt: paidAt ?? this.paidAt,
      dueDate: dueDate ?? this.dueDate,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
    );
  }

  // Méthodes utilitaires
  bool get isPending => status == 'pending';
  bool get isPaid => status == 'paid';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isOverdue =>
      dueDate != null && DateTime.now().isAfter(dueDate!) && !isPaid;

  @override
  String toString() {
    return 'ContributionModel(id: $id, user: $userId, group: $groupName, amount: $amount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ContributionModel &&
        other.id == id &&
        other.userId == userId &&
        other.groupId == groupId &&
        other.amount == amount &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    userId.hashCode ^
    groupId.hashCode ^
    amount.hashCode ^
    status.hashCode;
  }
}