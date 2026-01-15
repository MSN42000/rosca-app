// lib/screens/groups/group_details_screen.dart
import 'package:flutter/material.dart';
import '../../models/group_model.dart';
import '../../services/group_service.dart';
import '../../services/contribution_service.dart';
import '../../services/auth_service.dart';

class GroupDetailsScreen extends StatefulWidget {
  final String groupId;

  GroupDetailsScreen({required this.groupId});

  @override
  _GroupDetailsScreenState createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  final GroupService _groupService = GroupService();
  final ContributionService _contributionService = ContributionService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du groupe'),
      ),
      body: StreamBuilder<GroupModel?>(
        stream: _groupService.getGroupStream(widget.groupId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Groupe introuvable'));
          }

          final group = snapshot.data!;
          final currentUserId = _authService.currentUserId ?? '';
          final isAdmin = group.isAdmin(currentUserId);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête du groupe
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.group, size: 60, color: Colors.white),
                      SizedBox(height: 10),
                      Text(
                        group.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Round ${group.currentRound} / ${group.totalRounds}',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Informations du groupe
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informations',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      _buildInfoCard(
                        icon: Icons.attach_money,
                        label: 'Montant mensuel',
                        value: '${group.monthlyAmount.toStringAsFixed(2)} MAD',
                      ),
                      _buildInfoCard(
                        icon: Icons.people,
                        label: 'Membres',
                        value: '${group.activeMembersCount}',
                      ),
                      _buildInfoCard(
                        icon: Icons.calculate,
                        label: 'Total par round',
                        value:
                        '${group.totalAmountPerRound.toStringAsFixed(2)} MAD',
                      ),
                      _buildInfoCard(
                        icon: Icons.circle,
                        label: 'Statut',
                        value: group.status == 'active' ? 'Actif' : 'Terminé',
                        valueColor:
                        group.status == 'active' ? Colors.green : Colors.grey,
                      ),
                      SizedBox(height: 20),

                      // Liste des membres
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Membres (${group.members.length})',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          if (isAdmin)
                            TextButton.icon(
                              onPressed: () => _showAddMemberDialog(group),
                              icon: Icon(Icons.person_add),
                              label: Text('Ajouter'),
                            ),
                        ],
                      ),
                      SizedBox(height: 10),

                      if (group.members.isEmpty)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'Aucun membre pour le moment',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        ...group.members.map((member) {
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                  member.name.isNotEmpty
                                      ? member.name[0].toUpperCase()
                                      : '?',
                                ),
                              ),
                              title: Text(member.name),
                              subtitle: Text(member.email),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (member.hasReceived)
                                    Icon(Icons.check_circle,
                                        color: Colors.green),
                                  if (member.role == 'admin')
                                    Chip(
                                      label: Text('Admin',
                                          style: TextStyle(fontSize: 10)),
                                      backgroundColor: Colors.blue[100],
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Boutons d'action (si admin)
                if (isAdmin)
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton.icon(
                          onPressed: group.members.isEmpty
                              ? null
                              : () => _createRoundContributions(group),
                          icon: Icon(Icons.add_circle),
                          label: Text('Créer contributions du round'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                        SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: () => _nextRound(group),
                          icon: Icon(Icons.navigate_next),
                          label: Text('Passer au round suivant'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: Colors.grey[600])),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: valueColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ MÉTHODE CORRIGÉE - Utilise automatiquement l'userId de l'utilisateur connecté
  void _showAddMemberDialog(GroupModel group) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rejoindre le groupe'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nom',
                  hintText: 'Entrez votre nom',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Entrez votre email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty ||
                  emailController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Veuillez remplir tous les champs'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              // ✅ Récupérer l'userId de l'utilisateur connecté
              final currentUserId = _authService.currentUserId;

              if (currentUserId == null || currentUserId.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Vous devez être connecté'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              print('📝 Ajout membre: userId=$currentUserId');

              try {
                // ✅ Utiliser automatiquement l'userId de l'utilisateur connecté
                await _groupService.addMember(
                  groupId: group.id,
                  userId: currentUserId, // ✅ UserId automatique !
                  name: nameController.text.trim(),
                  email: emailController.text.trim(),
                );

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ Vous avez rejoint le groupe !'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Rejoindre'),
          ),
        ],
      ),
    );
  }

  void _nextRound(GroupModel group) async {
    if (group.currentRound >= group.totalRounds) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Le groupe a terminé tous ses rounds')),
      );
      return;
    }

    try {
      await _groupService.nextRound(groupId: group.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Round ${group.currentRound + 1} activé !')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  void _createRoundContributions(GroupModel group) async {
    if (group.members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ajoutez des membres avant de créer les contributions'),
        ),
      );
      return;
    }

    try {
      final memberIdsAndNames = <String, String>{};

      for (var member in group.members) {
        memberIdsAndNames[member.userId] = member.name;
        print('👤 Membre: userId=${member.userId}, name=${member.name}');
      }

      await _contributionService.createRoundContributionsForGroup(
        groupId: group.id,
        groupName: group.name,
        memberIdsAndNames: memberIdsAndNames,
        amount: group.monthlyAmount,
        roundNumber: group.currentRound,
        dueDate: null,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${memberIdsAndNames.length} contributions créées'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}