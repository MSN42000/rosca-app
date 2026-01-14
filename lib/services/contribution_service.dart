// lib/services/contribution_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/contribution_model.dart';

/// Service pour gérer les contributions des membres
class ContributionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // =====================================================
  // CRÉATION ET GESTION DES CONTRIBUTIONS
  // =====================================================

  /// Créer une nouvelle contribution
  Future<String> createContribution({
    required String userId,
    required String groupId,
    required String groupName,
    required double amount,
    required int roundNumber,
    DateTime? dueDate,
  }) async {
    final docRef = await _db.collection('contributions').add({
      'userId': userId,
      'groupId': groupId,
      'groupName': groupName,
      'amount': amount,
      'roundNumber': roundNumber,
      'status': 'pending',
      'paidAt': null,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate) : null,
      'approvedBy': null,
      'approvedAt': null,
    });

    return docRef.id;
  }

  /// Récupérer une contribution par ID
  Future<ContributionModel?> getContribution(String contributionId) async {
    final doc = await _db.collection('contributions').doc(contributionId).get();

    if (doc.exists && doc.data() != null) {
      return ContributionModel.fromFirestore(doc);
    }
    return null;
  }

  /// Stream d'une contribution (temps réel)
  Stream<ContributionModel?> getContributionStream(String contributionId) {
    return _db
        .collection('contributions')
        .doc(contributionId)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return ContributionModel.fromFirestore(doc);
      }
      return null;
    });
  }

  /// Supprimer une contribution
  Future<void> deleteContribution(String contributionId) async {
    await _db.collection('contributions').doc(contributionId).delete();
  }

  // =====================================================
  // MISE À JOUR DU STATUT
  // =====================================================

  /// Marquer une contribution comme payée
  Future<void> markAsPaid({
    required String contributionId,
  }) async {
    await _db.collection('contributions').doc(contributionId).update({
      'status': 'paid',
      'paidAt': FieldValue.serverTimestamp(),
    });
  }

  /// Approuver une contribution
  Future<void> approveContribution({
    required String contributionId,
    required String approvedBy,
  }) async {
    await _db.collection('contributions').doc(contributionId).update({
      'status': 'approved',
      'approvedBy': approvedBy,
      'approvedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Rejeter une contribution
  Future<void> rejectContribution({
    required String contributionId,
    required String rejectedBy,
  }) async {
    await _db.collection('contributions').doc(contributionId).update({
      'status': 'rejected',
      'approvedBy': rejectedBy,
      'approvedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Mettre à jour le statut d'une contribution
  Future<void> updateStatus({
    required String contributionId,
    required String newStatus,
  }) async {
    await _db.collection('contributions').doc(contributionId).update({
      'status': newStatus,
    });
  }

  // =====================================================
  // REQUÊTES PAR UTILISATEUR
  // =====================================================

  /// Récupérer toutes les contributions d'un utilisateur
  Future<List<ContributionModel>> getUserContributions(String userId) async {
    final snapshot = await _db
        .collection('contributions')
        .where('userId', isEqualTo: userId)
        .orderBy('roundNumber', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ContributionModel.fromFirestore(doc))
        .toList();
  }

  /// Stream des contributions d'un utilisateur
  Stream<List<ContributionModel>> getUserContributionsStream(String userId) {
    return _db
        .collection('contributions')
        .where('userId', isEqualTo: userId)
        .orderBy('roundNumber', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ContributionModel.fromFirestore(doc))
        .toList());
  }

  /// Récupérer les contributions en attente d'un utilisateur
  Future<List<ContributionModel>> getUserPendingContributions(
      String userId) async {
    final snapshot = await _db
        .collection('contributions')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .get();

    return snapshot.docs
        .map((doc) => ContributionModel.fromFirestore(doc))
        .toList();
  }

  // =====================================================
  // REQUÊTES PAR GROUPE
  // =====================================================

  /// Récupérer toutes les contributions d'un groupe
  Future<List<ContributionModel>> getGroupContributions(String groupId) async {
    final snapshot = await _db
        .collection('contributions')
        .where('groupId', isEqualTo: groupId)
        .orderBy('roundNumber', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ContributionModel.fromFirestore(doc))
        .toList();
  }

  /// Stream des contributions d'un groupe
  Stream<List<ContributionModel>> getGroupContributionsStream(String groupId) {
    return _db
        .collection('contributions')
        .where('groupId', isEqualTo: groupId)
        .orderBy('roundNumber', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ContributionModel.fromFirestore(doc))
        .toList());
  }

  /// Récupérer les contributions d'un round spécifique
  Future<List<ContributionModel>> getGroupRoundContributions({
    required String groupId,
    required int roundNumber,
  }) async {
    final snapshot = await _db
        .collection('contributions')
        .where('groupId', isEqualTo: groupId)
        .where('roundNumber', isEqualTo: roundNumber)
        .get();

    return snapshot.docs
        .map((doc) => ContributionModel.fromFirestore(doc))
        .toList();
  }

  /// Récupérer les contributions approuvées d'un groupe
  Future<List<ContributionModel>> getGroupApprovedContributions(
      String groupId) async {
    final snapshot = await _db
        .collection('contributions')
        .where('groupId', isEqualTo: groupId)
        .where('status', isEqualTo: 'approved')
        .get();

    return snapshot.docs
        .map((doc) => ContributionModel.fromFirestore(doc))
        .toList();
  }

  // =====================================================
  // STATISTIQUES
  // =====================================================

  /// Calculer le total des contributions d'un utilisateur
  Future<double> getUserTotalContributions(String userId) async {
    final contributions = await getUserContributions(userId);
    return contributions
        .where((c) => c.isApproved || c.isPaid)
        .fold<double>(0.0, (sum, c) => sum + c.amount);
  }

  /// Calculer le total des contributions d'un groupe
  Future<double> getGroupTotalContributions(String groupId) async {
    final contributions = await getGroupContributions(groupId);
    return contributions
        .where((c) => c.isApproved || c.isPaid)
        .fold<double>(0.0, (sum, c) => sum + c.amount);

  }

  /// Récupérer le nombre de contributions en retard
  Future<int> getOverdueContributionsCount(String userId) async {
    final contributions = await getUserContributions(userId);
    return contributions.where((c) => c.isOverdue).length;
  }

  /// Créer des contributions pour tous les membres d'un groupe
  Future<void> createRoundContributionsForGroup({
    required String groupId,
    required String groupName,
    required List<String> memberIds,
    required double amount,
    required int roundNumber,
    DateTime? dueDate,
  }) async {
    final batch = _db.batch();

    for (String memberId in memberIds) {
      final docRef = _db.collection('contributions').doc();
      batch.set(docRef, {
        'userId': memberId,
        'groupId': groupId,
        'groupName': groupName,
        'amount': amount,
        'roundNumber': roundNumber,
        'status': 'pending',
        'paidAt': null,
        'dueDate': dueDate != null ? Timestamp.fromDate(dueDate) : null,
        'approvedBy': null,
        'approvedAt': null,
      });
    }

    await batch.commit();
  }

  /// Récupérer le nombre total de contributions
  Future<int> getTotalContributionsCount() async {
    final snapshot = await _db.collection('contributions').count().get();
    return snapshot.count ?? 0;
  }
}