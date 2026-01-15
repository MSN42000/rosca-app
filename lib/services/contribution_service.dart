// lib/services/contribution_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/contribution_model.dart';

class ContributionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // =====================================================
  // CRÉATION ET GESTION
  // =====================================================

  /// Créer une nouvelle contribution
  Future<String> createContribution({
    required String userId,
    required String userName,
    required String groupId,
    required String groupName,
    required double amount,
    required int roundNumber,
    DateTime? dueDate,
  }) async {
    final docRef = await _db.collection('contributions').add({
      'userId': userId,
      'userName': userName,
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

  /// Stream d'une contribution
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
  Future<void> markAsPaid({required String contributionId}) async {
    await _db.collection('contributions').doc(contributionId).update({
      'status': 'paid',
      'paidAt': FieldValue.serverTimestamp(),
    });
  }

  /// Approuver une contribution (par un admin)
  Future<void> approveContribution({
    required String contributionId,
    required String approvedByUserId,
  }) async {
    await _db.collection('contributions').doc(contributionId).update({
      'status': 'approved',
      'approvedBy': approvedByUserId,
      'approvedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Rejeter une contribution
  Future<void> rejectContribution({
    required String contributionId,
    required String rejectedByUserId,
  }) async {
    await _db.collection('contributions').doc(contributionId).update({
      'status': 'rejected',
      'approvedBy': rejectedByUserId,
      'approvedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Mettre à jour le statut
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
        .snapshots()
        .map((snapshot) {
      var docs = snapshot.docs
          .map((doc) => ContributionModel.fromFirestore(doc))
          .toList();

      // Trier côté client
      docs.sort((a, b) => b.roundNumber.compareTo(a.roundNumber));
      return docs;
    });
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

  /// Récupérer les contributions payées mais non approuvées d'un utilisateur
  Future<List<ContributionModel>> getUserPaidNotApprovedContributions(
      String userId) async {
    final snapshot = await _db
        .collection('contributions')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'paid')
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

  /// Récupérer les contributions en attente d'approbation pour un groupe
  Future<List<ContributionModel>> getGroupPaidContributions(
      String groupId) async {
    final snapshot = await _db
        .collection('contributions')
        .where('groupId', isEqualTo: groupId)
        .where('status', isEqualTo: 'paid')
        .get();

    return snapshot.docs
        .map((doc) => ContributionModel.fromFirestore(doc))
        .toList();
  }

  /// Stream des contributions en attente d'approbation
  Stream<List<ContributionModel>> getGroupPaidContributionsStream(
      String groupId) {
    return _db
        .collection('contributions')
        .where('groupId', isEqualTo: groupId)
        .where('status', isEqualTo: 'paid')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ContributionModel.fromFirestore(doc))
            .toList());
  }

  // =====================================================
  // STATISTIQUES
  // =====================================================

  /// Calculer le total des contributions d'un utilisateur
  Future<double> getUserTotalContributions(String userId) async {
    final contributions = await getUserContributions(userId);
    return contributions
        .where((c) => c.isApproved)
        .fold<double>(0.0, (sum, c) => sum + c.amount);
  }

  /// Calculer le total des contributions d'un groupe
  Future<double> getGroupTotalContributions(String groupId) async {
    final contributions = await getGroupContributions(groupId);
    return contributions
        .where((c) => c.isApproved)
        .fold<double>(0.0, (sum, c) => sum + c.amount);
  }

  /// Compter les contributions par statut pour un utilisateur
  Future<Map<String, int>> getUserContributionsCountByStatus(
      String userId) async {
    final contributions = await getUserContributions(userId);
    return {
      'pending': contributions.where((c) => c.isPending).length,
      'paid': contributions.where((c) => c.isPaid).length,
      'approved': contributions.where((c) => c.isApproved).length,
      'rejected': contributions.where((c) => c.isRejected).length,
    };
  }

  /// Compter les contributions par statut pour un groupe
  Future<Map<String, int>> getGroupContributionsCountByStatus(
      String groupId) async {
    final contributions = await getGroupContributions(groupId);
    return {
      'pending': contributions.where((c) => c.isPending).length,
      'paid': contributions.where((c) => c.isPaid).length,
      'approved': contributions.where((c) => c.isApproved).length,
      'rejected': contributions.where((c) => c.isRejected).length,
    };
  }

  /// Créer des contributions pour tous les membres d'un groupe
  Future<void> createRoundContributionsForGroup({
    required String groupId,
    required String groupName,
    required Map<String, String> memberIdsAndNames, // userId: userName
    required double amount,
    required int roundNumber,
    DateTime? dueDate,
  }) async {
    final batch = _db.batch();

    memberIdsAndNames.forEach((memberId, memberName) {
      final docRef = _db.collection('contributions').doc();
      batch.set(docRef, {
        'userId': memberId,
        'userName': memberName,
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
    });

    await batch.commit();
  }

  /// Récupérer le nombre total de contributions
  Future<int> getTotalContributionsCount() async {
    final snapshot = await _db.collection('contributions').count().get();
    return snapshot.count ?? 0;
  }

  /// Récupérer les contributions en retard
  Future<List<ContributionModel>> getOverdueContributions(String userId) async {
    final contributions = await getUserContributions(userId);
    return contributions.where((c) => c.isOverdue).toList();
  }
}
