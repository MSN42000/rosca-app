// lib/models/contribution_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ContributionModel {
  final String id;
  final String userId;
  final String groupId;
  final double amount;
  final int roundNumber;
  final String status; // "pending", "paid"
  final DateTime? paidAt;

  ContributionModel({
    required this.id,
    required this.userId,
    required this.groupId,
    required this.amount,
    required this.roundNumber,
    this.status = 'pending',
    this.paidAt,
  });

  // Depuis Firestore
  factory ContributionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ContributionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      groupId: data['groupId'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      roundNumber: data['roundNumber'] ?? 0,
      status: data['status'] ?? 'pending',
      paidAt: data['paidAt'] != null
          ? (data['paidAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Vers Map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'groupId': groupId,
      'amount': amount,
      'roundNumber': roundNumber,
      'status': status,
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
    };
  }

  // CopyWith
  ContributionModel copyWith({
    String? id,
    String? userId,
    String? groupId,
    double? amount,
    int? roundNumber,
    String? status,
    DateTime? paidAt,
  }) {
    return ContributionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      groupId: groupId ?? this.groupId,
      amount: amount ?? this.amount,
      roundNumber: roundNumber ?? this.roundNumber,
      status: status ?? this.status,
      paidAt: paidAt ?? this.paidAt,
    );
  }

  // Méthodes utilitaires
  bool get isPending => status == 'pending';
  bool get isPaid => status == 'paid';
}