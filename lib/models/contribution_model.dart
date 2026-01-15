// lib/models/contribution_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ContributionModel {
  final String id;
  final String userId;
  final String userName;
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
    required this.userName,
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
      userName: data['userName'] ?? 'Utilisateur inconnu',
      groupId: data['groupId'] ?? '',
      groupName: data['groupName'] ?? 'Groupe sans nom',
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

  // Vers Map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'groupId': groupId,
      'groupName': groupName,
      'amount': amount,
      'roundNumber': roundNumber,
      'status': status,
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
    };
  }

  // CopyWith
  ContributionModel copyWith({
    String? id,
    String? userId,
    String? userName,
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
      userName: userName ?? this.userName,
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

  // Vérifie si la contribution est en retard
  bool get isOverdue {
    if (dueDate == null || isPaid || isApproved) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  // Nombre de jours avant/après la date limite
  int? get daysUntilDue {
    if (dueDate == null) return null;
    final now = DateTime.now();
    final difference =
        dueDate!.difference(DateTime(now.year, now.month, now.day));
    return difference.inDays;
  }
}
