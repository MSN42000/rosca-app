// lib/models/round.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single collection round inside a ROSCA group.
/// A round tracks payments, deadlines, and the beneficiary.
class Round {

  /// Firestore document ID of the round
  final String id;

  /// Parent ROSCA group ID
  final String groupId;

  /// Sequential number of the round (starts at 1)
  final int roundNumber;

  /// User ID of the beneficiary for this round
  final String recipientId;

  /// Deadline for members to complete their contribution
  final DateTime dueDate;

  /// Optional start date of the round
  final DateTime? startDate;

  /// Set when all members have completed their payments
  final DateTime? completedDate;

  /// Tracks payment status per member (userId → paid / not paid)
  final Map<String, bool> contributions;

  /// Optional detailed payment information (amount, date, method)
  final Map<String, dynamic>? contributionDetails;

  /// Amount already collected for this round
  final double totalCollected;

  /// Expected amount once all members have paid
  final double totalExpected;

  /// Current lifecycle status of the round
  final String status;

  /// Firestore creation timestamp
  final DateTime? createdAt;

  /// Firestore last update timestamp
  final DateTime? updatedAt;

  /// Optional notes related to this round
  final String? notes;

  /// Main constructor
  Round({
    required this.id,
    required this.groupId,
    required this.roundNumber,
    required this.recipientId,
    required this.dueDate,
    this.startDate,
    this.completedDate,
    required this.contributions,
    this.contributionDetails,
    this.totalCollected = 0,
    required this.totalExpected,
    this.status = 'pending',
    this.createdAt,
    this.updatedAt,
    this.notes,
  });

  /// Builds a Round instance from a Firestore document
  factory Round.fromFirestore(DocumentSnapshot doc, String groupId) {
    final data = doc.data() as Map<String, dynamic>;

    return Round(
      id: doc.id,
      groupId: groupId,
      roundNumber: data['roundNumber'] ?? 0,
      recipientId: data['recipientId'] ?? '',
      dueDate: (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startDate: (data['startDate'] as Timestamp?)?.toDate(),
      completedDate: (data['completedDate'] as Timestamp?)?.toDate(),
      contributions: Map<String, bool>.from(data['contributions'] ?? {}),
      contributionDetails: data['contributionDetails'] != null
          ? Map<String, dynamic>.from(data['contributionDetails'])
          : null,
      totalCollected: (data['totalCollected'] ?? 0).toDouble(),
      totalExpected: (data['totalExpected'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      notes: data['notes'],
    );
  }

  /// Converts the round into a Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'roundNumber': roundNumber,
      'recipientId': recipientId,
      'dueDate': Timestamp.fromDate(dueDate),
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'completedDate':
      completedDate != null ? Timestamp.fromDate(completedDate!) : null,
      'contributions': contributions,
      'contributionDetails': contributionDetails,
      'totalCollected': totalCollected,
      'totalExpected': totalExpected,
      'status': status,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'notes': notes,
    };
  }

  /// Returns a modified copy of the current round
  Round copyWith({
    int? roundNumber,
    String? recipientId,
    DateTime? dueDate,
    DateTime? startDate,
    DateTime? completedDate,
    Map<String, bool>? contributions,
    Map<String, dynamic>? contributionDetails,
    double? totalCollected,
    double? totalExpected,
    String? status,
    String? notes,
  }) {
    return Round(
      id: id,
      groupId: groupId,
      roundNumber: roundNumber ?? this.roundNumber,
      recipientId: recipientId ?? this.recipientId,
      dueDate: dueDate ?? this.dueDate,
      startDate: startDate ?? this.startDate,
      completedDate: completedDate ?? this.completedDate,
      contributions: contributions ?? this.contributions,
      contributionDetails:
      contributionDetails ?? this.contributionDetails,
      totalCollected: totalCollected ?? this.totalCollected,
      totalExpected: totalExpected ?? this.totalExpected,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      notes: notes ?? this.notes,
    );
  }

  /// Total number of members involved in this round
  int get memberCount => contributions.length;

  /// Number of members who have already paid
  int get paidCount =>
      contributions.values.where((paid) => paid).length;

  /// Number of members who have not yet paid
  int get unpaidCount => memberCount - paidCount;

  /// Completion percentage of the round
  double get completionPercentage {
    if (memberCount == 0) return 0;
    return (paidCount / memberCount * 100).clamp(0, 100);
  }

  /// Remaining amount to be collected
  double get remainingAmount => totalExpected - totalCollected;

  /// Checks whether a specific member has paid
  bool hasPaid(String userId) => contributions[userId] == true;

  /// Indicates whether all members have completed their payments
  bool get isFullyPaid => paidCount == memberCount && memberCount > 0;

  /// Indicates whether the round is overdue
  bool get isOverdue =>
      DateTime.now().isAfter(dueDate) && !isFullyPaid;

  /// Number of days before or after the due date
  int get daysRemaining =>
      dueDate.difference(DateTime.now()).inDays;

  /// Human-readable due date status
  String get dueDateStatus {
    if (isFullyPaid) return 'Completed';

    final days = daysRemaining;

    if (days > 0) {
      return '$days day${days > 1 ? 's' : ''} remaining';
    } else if (days == 0) {
      return 'Due today';
    } else {
      final late = days.abs();
      return '$late day${late > 1 ? 's' : ''} overdue';
    }
  }

  /// List of members who have paid
  List<String> get paidMembers =>
      contributions.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

  /// List of members who have not yet paid
  List<String> get unpaidMembers =>
      contributions.entries
          .where((e) => !e.value)
          .map((e) => e.key)
          .toList();

  /// Indicates whether the round can be safely closed
  bool get canBeCompleted =>
      isFullyPaid && totalCollected >= totalExpected;

  @override
  String toString() {
    return 'Round(round: $roundNumber, paid: $paidCount/$memberCount, '
        'amount: $totalCollected/$totalExpected, status: $status)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Round && other.id == id && other.groupId == groupId;

  @override
  int get hashCode => id.hashCode ^ groupId.hashCode;
}
