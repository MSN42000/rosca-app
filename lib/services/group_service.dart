// lib/services/group_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group_model.dart';

/// Service pour gérer les opérations sur les groupes
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
    List<String>? adminIds,
  }) async {
    final docRef = await _db.collection('groups').add({
      'name': name,
      'monthlyAmount': monthlyAmount,
      'currentRound': 1,
      'totalRounds': totalRounds,
      'currentReceiverId': null,
      'adminIds': adminIds ?? [createdBy],
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

  /// Stream d'un groupe (temps réel)
  Stream<GroupModel?> getGroupStream(String groupId) {
    return _db.collection('groups').doc(groupId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return GroupModel.fromFirestore(doc);
      }
      return null;
    });
  }

  /// Mettre à jour les informations d'un groupe
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
    String role = 'member',
  }) async {
    final group = await getGroup(groupId);
    if (group == null) throw Exception('Groupe introuvable');

    final newMember = GroupMember(
      userId: userId,
      name: name,
      email: email,
      joinOrder: group.members.length + 1,
      role: role,
      status: 'active',
      hasReceived: false,
      joinedAt: DateTime.now(),
    );

    await _db.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayUnion([newMember.toMap()]),
    });

    // Mettre à jour le profil utilisateur
    await _db.collection('users').doc(userId).update({
      'groupIds': FieldValue.arrayUnion([groupId]),
    });
  }

  /// Retirer un membre du groupe
  Future<void> removeMember({
    required String groupId,
    required String userId,
  }) async {
    final group = await getGroup(groupId);
    if (group == null) return;

    final memberToRemove =
    group.members.firstWhere((m) => m.userId == userId);

    await _db.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayRemove([memberToRemove.toMap()]),
    });

    // Mettre à jour le profil utilisateur
    await _db.collection('users').doc(userId).update({
      'groupIds': FieldValue.arrayRemove([groupId]),
    });
  }

  /// Mettre à jour le statut d'un membre
  Future<void> updateMemberStatus({
    required String groupId,
    required String userId,
    required String newStatus,
  }) async {
    final group = await getGroup(groupId);
    if (group == null) return;

    final updatedMembers = group.members.map((member) {
      if (member.userId == userId) {
        return member.copyWith(status: newStatus);
      }
      return member;
    }).toList();

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
  Future<void> nextRound({
    required String groupId,
    String? nextReceiverId,
  }) async {
    final group = await getGroup(groupId);
    if (group == null) return;

    await _db.collection('groups').doc(groupId).update({
      'currentRound': group.currentRound + 1,
      'currentReceiverId': nextReceiverId,
    });
  }

  /// Définir le bénéficiaire actuel
  Future<void> setCurrentReceiver({
    required String groupId,
    required String receiverId,
  }) async {
    await _db.collection('groups').doc(groupId).update({
      'currentReceiverId': receiverId,
    });
  }

  // =====================================================
  // GESTION DES ADMINS
  // =====================================================

  /// Ajouter un admin
  Future<void> addAdmin({
    required String groupId,
    required String userId,
  }) async {
    await _db.collection('groups').doc(groupId).update({
      'adminIds': FieldValue.arrayUnion([userId]),
    });

    // Mettre à jour le profil utilisateur
    await _db.collection('users').doc(userId).update({
      'adminGroupIds': FieldValue.arrayUnion([groupId]),
    });
  }

  /// Retirer un admin
  Future<void> removeAdmin({
    required String groupId,
    required String userId,
  }) async {
    await _db.collection('groups').doc(groupId).update({
      'adminIds': FieldValue.arrayRemove([userId]),
    });

    // Mettre à jour le profil utilisateur
    await _db.collection('users').doc(userId).update({
      'adminGroupIds': FieldValue.arrayRemove([groupId]),
    });
  }

  // =====================================================
  // REQUÊTES ET LISTES
  // =====================================================

  /// Récupérer tous les groupes d'un utilisateur
  Future<List<GroupModel>> getUserGroups(String userId) async {
    final snapshot = await _db
        .collection('groups')
        .where('members', arrayContains: {'userId': userId})
        .get();

    return snapshot.docs.map((doc) => GroupModel.fromFirestore(doc)).toList();
  }

  /// Stream des groupes d'un utilisateur
  Stream<List<GroupModel>> getUserGroupsStream(String userId) {
    return _db
        .collection('groups')
        .where('adminIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => GroupModel.fromFirestore(doc)).toList());
  }

  /// Récupérer tous les groupes actifs
  Future<List<GroupModel>> getActiveGroups() async {
    final snapshot = await _db
        .collection('groups')
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => GroupModel.fromFirestore(doc)).toList();
  }

  /// Récupérer les groupes créés par un utilisateur
  Future<List<GroupModel>> getGroupsCreatedBy(String userId) async {
    final snapshot = await _db
        .collection('groups')
        .where('createdBy', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => GroupModel.fromFirestore(doc)).toList();
  }

  /// Vérifier si un utilisateur est admin d'un groupe
  Future<bool> isUserAdmin(String groupId, String userId) async {
    final group = await getGroup(groupId);
    return group?.isAdmin(userId) ?? false;
  }

  /// Récupérer le nombre total de groupes
  Future<int> getTotalGroupsCount() async {
    final snapshot = await _db.collection('groups').count().get();
    return snapshot.count ?? 0;
  }
}