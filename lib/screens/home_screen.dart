import 'package:flutter/material.dart';
import 'groups/create_group_screen.dart';
import 'contributions/my_contributions_screen.dart';
import '../services/auth_service.dart';
import '../services/group_service.dart';
import '../models/group_model.dart';
import 'groups/group_details_screen.dart';

class HomeScreen extends StatelessWidget {
  final AuthService _authService = AuthService();
  final GroupService _groupService = GroupService();

  @override
  Widget build(BuildContext context) {
    final currentUserId = _authService.currentUserId ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Groupes'),
        actions: [
          IconButton(
            icon: Icon(Icons.receipt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MyContributionsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: StreamBuilder<List<GroupModel>>(
        stream: _groupService.getUserGroupsStream(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group, size: 100, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'Aucun groupe',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateGroupScreen(),
                        ),
                      );
                    },
                    icon: Icon(Icons.add),
                    label: Text('Créer un groupe'),
                  ),
                ],
              ),
            );
          }

          final groups = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.group),
                  ),
                  title: Text(
                    group.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Round ${group.currentRound}/${group.totalRounds} • ${group.activeMembersCount} membres',
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${group.monthlyAmount.toStringAsFixed(0)} MAD',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        group.status == 'active' ? 'Actif' : 'Terminé',
                        style: TextStyle(
                          color: group.status == 'active'
                              ? Colors.green
                              : Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            GroupDetailsScreen(groupId: group.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CreateGroupScreen()),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Créer un groupe',
      ),
    );
  }
}