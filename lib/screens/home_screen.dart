import 'package:flutter/material.dart';
import 'package:rosca_app/screens/auth/login_screen.dart';
import 'package:rosca_app/theme/app_theme.dart';
import 'package:rosca_app/widgets/custom_appbar.dart';
import 'groups/create_group_screen.dart';
import 'contributions/my_contributions_screen.dart';
import '../services/auth_service.dart';
import '../services/group_service.dart';
import '../models/group_model.dart';
import 'groups/group_details_screen.dart';
import '../widgets/group_card.dart';

class HomeScreen extends StatelessWidget {
  final AuthService _authService = AuthService();
  final GroupService _groupService = GroupService();

  @override
  Widget build(BuildContext context) {
    final currentUserId = _authService.currentUserId ?? '';

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Mes Groupes',
        showBackButton: false,
        actions: [
          IconButton(
            icon: Icon(Icons.receipt, color: Colors.white),
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
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await _authService.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
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
              return GroupCard(
                group: group,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GroupDetailsScreen(groupId: group.id),
                    ),
                  );
                },
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
        tooltip: 'Créer un groupe',
        backgroundColor: AppColors.primaryLight,
        child: Icon(
          Icons.add,
          color: AppColors.background,
        ),
      ),
    );
  }
}
