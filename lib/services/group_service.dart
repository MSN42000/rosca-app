// lib/services/group_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group_model.dart';
import 'package:rosca_app/screens/contributions/my_contributions_screen.dart';
class GroupService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // =====================================================
  // CRÉATION ET GESTION DES GROUPES
  // =====================================================

  /// Créer un nouveau groupe
  Future<String> createGroup({
    required String name,
    required double monthlyAmount,
    required int totalRounds,
    required String createdBy,
  }) async {
    final docRef = await _db.collection('groups').add({
      'name': name,
      'monthlyAmount': monthlyAmount,
      'currentRound': 1,
      'totalRounds': totalRounds,
      'createdBy': createdBy,
      'status': 'active',
      'members': [],
      'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  /// Récupérer un groupe par ID
  Future<GroupModel?> getGroup(String groupId) async {
    final doc = await _db.collection('groups').doc(groupId).get();
    if (doc.exists && doc.data() != null) {
      return GroupModel.fromFirestore(doc);
    }
    return null;
  }

  /// Stream d'un groupe
  Stream<GroupModel?> getGroupStream(String groupId) {
    return _db.collection('groups').doc(groupId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return GroupModel.fromFirestore(doc);
      }
      return null;
    });
  }

  /// Mettre à jour un groupe
  Future<void> updateGroup({
    required String groupId,
    String? name,
    double? monthlyAmount,
    int? totalRounds,
    String? status,
  }) async {
    final Map<String, dynamic> updates = {};
    if (name != null) updates['name'] = name;
    if (monthlyAmount != null) updates['monthlyAmount'] = monthlyAmount;
    if (totalRounds != null) updates['totalRounds'] = totalRounds;
    if (status != null) updates['status'] = status;

    if (updates.isNotEmpty) {
      await _db.collection('groups').doc(groupId).update(updates);
    }
  }

  /// Supprimer un groupe
  Future<void> deleteGroup(String groupId) async {
    await _db.collection('groups').doc(groupId).delete();
  }

  // =====================================================
  // GESTION DES MEMBRES
  // =====================================================

  /// Ajouter un membre au groupe
  Future<void> addMember({
    required String groupId,
    required String userId,
    required String name,
    required String email,
  }) async {
    final group = await getGroup(groupId);
    if (group == null) throw Exception('Groupe introuvable');

    // Vérifier si le membre existe déjà
    if (group.members.any((m) => m.userId == userId)) {
      throw Exception('Ce membre fait déjà partie du groupe');
    }

    final newMember = GroupMember(
      userId: userId,
      name: name,
      email: email,
      joinOrder: group.members.length + 1,
      role: 'member',
      hasReceived: false,
    );

    final updatedMembers = [...group.members, newMember];

    await _db.collection('groups').doc(groupId).update({
      'members': updatedMembers.map((m) => m.toMap()).toList(),
    });
  }

  /// Retirer un membre du groupe
  Future<void> removeMember({
    required String groupId,
    required String userId,
  }) async {
    final group = await getGroup(groupId);
    if (group == null) return;

    final updatedMembers = group.members.where((m) => m.userId != userId).toList();

    await _db.collection('groups').doc(groupId).update({
      'members': updatedMembers.map((m) => m.toMap()).toList(),
    });
  }

  /// Marquer qu'un membre a reçu sa part
  Future<void> markMemberAsReceived({
    required String groupId,
    required String userId,
  }) async {
    final group = await getGroup(groupId);
    if (group == null) return;

    final updatedMembers = group.members.map((member) {
      if (member.userId == userId) {
        return member.copyWith(hasReceived: true);
      }
      return member;
    }).toList();

    await _db.collection('groups').doc(groupId).update({
      'members': updatedMembers.map((m) => m.toMap()).toList(),
    });
  }

  // =====================================================
  // GESTION DES ROUNDS
  // =====================================================

  /// Passer au round suivant
  Future<void> nextRound({required String groupId}) async {
    final group = await getGroup(groupId);
    if (group == null) return;

    await _db.collection('groups').doc(groupId).update({
      'currentRound': group.currentRound + 1,
    });
  }

  // =====================================================
  // REQUÊTES
  // =====================================================

  /// Stream des groupes d'un utilisateur
  Stream<List<GroupModel>> getUserGroupsStream(String userId) {
    return _db
        .collection('groups')
        .where('createdBy', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => GroupModel.fromFirestore(doc)).toList());
  }

  /// Récupérer tous les groupes actifs
  Future<List<GroupModel>> getActiveGroups() async {
    final snapshot = await _db
        .collection('groups')
        .where('status', isEqualTo: 'active')
        .get();

    return snapshot.docs.map((doc) => GroupModel.fromFirestore(doc)).toList();
  }

  /// Vérifier si un utilisateur est admin d'un groupe
  Future<bool> isUserAdmin(String groupId, String userId) async {
    final group = await getGroup(groupId);
    return group?.isAdmin(userId) ?? false;
  }
}