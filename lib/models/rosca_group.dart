// lib/models/rosca_group.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a ROSCA (tontine) group.
/// This model reflects both the business logic and
/// the Firestore document structure.
class RoscaGroup {

  /// Unique identifier of the group (Firestore document ID)
  final String id;

  /// Name displayed to users
  final String name;

  /// Optional description to explain the purpose of the group
  final String? description;

  /// Total amount collected at each round
  /// (contributionPerMember × number of members)
  final double totalAmount;

  /// Amount paid by each member per round
  final double contributionPerMember;

  /// Frequency of contributions (monthly, weekly, etc.)
  final String frequency;

  /// Date when the group starts
  final DateTime startDate;

  /// Automatically calculated end date (optional)
  final DateTime? endDate;

  /// User ID of the group administrator
  final String adminId;

  /// List of member user IDs
  /// The order can define the payout order
  final List<String> members;

  /// Current round number (starts from 1)
  final int currentRound;

  /// Current status of the group
  final String status;

  /// Timestamp of creation
  final DateTime? createdAt;

  /// Timestamp of last update
  final DateTime? updatedAt;

  /// Optional custom distribution order
  final List<String>? distributionOrder;

  /// Method used to select the beneficiary
  final String selectionMethod;

  /// Optional rules (penalties, bonuses, conditions)
  final Map<String, dynamic>? rules;

  /// Main constructor
  RoscaGroup({
    required this.id,
    required this.name,
    this.description,
    required this.totalAmount,
    required this.contributionPerMember,
    required this.frequency,
    required this.startDate,
    this.endDate,
    required this.adminId,
    required this.members,
    this.currentRound = 1,
    this.status = 'pending',
    this.createdAt,
    this.updatedAt,
    this.distributionOrder,
    this.selectionMethod = 'sequential',
    this.rules,
  });

  /// Creates a RoscaGroup from a Firestore document
  factory RoscaGroup.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return RoscaGroup(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      contributionPerMember: (data['contributionPerMember'] ?? 0).toDouble(),
      frequency: data['frequency'] ?? 'monthly',
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
      adminId: data['adminId'] ?? '',
      members: List<String>.from(data['members'] ?? []),
      currentRound: data['currentRound'] ?? 1,
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      distributionOrder: data['distributionOrder'] != null
          ? List<String>.from(data['distributionOrder'])
          : null,
      selectionMethod: data['selectionMethod'] ?? 'sequential',
      rules: data['rules'] != null
          ? Map<String, dynamic>.from(data['rules'])
          : null,
    );
  }

  /// Converts the object into a Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'totalAmount': totalAmount,
      'contributionPerMember': contributionPerMember,
      'frequency': frequency,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'adminId': adminId,
      'members': members,
      'currentRound': currentRound,
      'status': status,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'distributionOrder': distributionOrder,
      'selectionMethod': selectionMethod,
      'rules': rules,
    };
  }

  /// Creates a modified copy of the current group
  RoscaGroup copyWith({
    String? name,
    String? description,
    double? totalAmount,
    double? contributionPerMember,
    String? frequency,
    DateTime? startDate,
    DateTime? endDate,
    String? adminId,
    List<String>? members,
    int? currentRound,
    String? status,
    List<String>? distributionOrder,
    String? selectionMethod,
    Map<String, dynamic>? rules,
  }) {
    return RoscaGroup(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      totalAmount: totalAmount ?? this.totalAmount,
      contributionPerMember:
      contributionPerMember ?? this.contributionPerMember,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      adminId: adminId ?? this.adminId,
      members: members ?? this.members,
      currentRound: currentRound ?? this.currentRound,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      distributionOrder: distributionOrder ?? this.distributionOrder,
      selectionMethod: selectionMethod ?? this.selectionMethod,
      rules: rules ?? this.rules,
    );
  }

  /// Number of members in the group
  int get memberCount => members.length;

  /// Total number of rounds (one per member)
  int get totalRounds => members.length;

  /// Returns true if the group has completed all rounds
  bool get isCompleted =>
      status == 'completed' || currentRound > totalRounds;

  /// Checks whether a user belongs to the group
  bool isMember(String userId) => members.contains(userId);

  /// Checks whether a user is the group admin
  bool isAdmin(String userId) => adminId == userId;

  /// Returns the beneficiary for a given round
  String? getRecipientForRound(int roundNumber) {
    if (roundNumber < 1 || roundNumber > totalRounds) return null;

    final index = roundNumber - 1;

    if (distributionOrder != null && index < distributionOrder!.length) {
      return distributionOrder![index];
    }

    return members[index];
  }

  /// Calculates the expected date of a specific round
  DateTime? getDateForRound(int roundNumber) {
    if (roundNumber < 1 || roundNumber > totalRounds) return null;

    final offset = roundNumber - 1;

    switch (frequency) {
      case 'weekly':
        return startDate.add(Duration(days: offset * 7));
      case 'monthly':
        return DateTime(startDate.year, startDate.month + offset, startDate.day);
      case 'yearly':
        return DateTime(startDate.year + offset, startDate.month, startDate.day);
      default:
        return startDate;
    }
  }

  @override
  String toString() {
    return 'RoscaGroup(id: $id, name: $name, round: $currentRound/$totalRounds)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is RoscaGroup && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
