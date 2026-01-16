// lib/screens/groups/group_details_screen.dart
import 'package:flutter/material.dart';
import 'package:rosca_app/widgets/app_text_file.dart';
import '../../models/group_model.dart';
import '../../services/group_service.dart';
import '../../services/contribution_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_button.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_style.dart';
import '../../theme/app_theme.dart';

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
      appBar: CustomAppBar(
        title: 'Détails du groupe',
        centerTitle: true,
      ),
      body: StreamBuilder<GroupModel?>(
        stream: _groupService.getGroupStream(widget.groupId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: AppColors.error),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'Erreur: ${snapshot.error}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_off,
                      size: 60, color: AppColors.textDisabled),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'Groupe introuvable',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textDisabled,
                    ),
                  ),
                ],
              ),
            );
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
                  padding: EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    // borderRadius: BorderRadius.only(
                    //   bottomLeft: Radius.circular(AppSpacing.radiusLg),
                    //   bottomRight: Radius.circular(AppSpacing.radiusLg),
                    // ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.group,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        group.name,
                        style: AppTextStyles.displaySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Text(
                          'Round ${group.currentRound} / ${group.totalRounds}',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.lg),

                // Informations du groupe
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informations',
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 25,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.md),
                      _buildInfoCard(
                        icon: Icons.attach_money,
                        label: 'Montant mensuel',
                        value: '${group.monthlyAmount.toStringAsFixed(2)} MAD',
                        valueColor: AppColors.secondary,
                      ),
                      _buildInfoCard(
                        icon: Icons.people,
                        label: 'Membres',
                        value: '${group.activeMembersCount}',
                        valueColor: AppColors.lavendar,
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
                        valueColor: group.status == 'active'
                            ? AppColors.success
                            : AppColors.secondary,
                      ),
                      SizedBox(height: AppSpacing.lg),

                      // Liste des membres
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Membres (${group.members.length})',
                            style: AppTextStyles.titleLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (isAdmin)
                            CustomTextButton(
                              text: 'Ajouter',
                              onPressed: () => _showAddMemberDialog(group),
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.md),

                      if (group.members.isEmpty)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.xl),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 60,
                                  color: AppColors.textDisabled,
                                ),
                                SizedBox(height: AppSpacing.md),
                                Text(
                                  'Aucun membre pour le moment',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textDisabled,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...group.members.map((member) {
                          return Card(
                            margin: EdgeInsets.only(bottom: AppSpacing.sm),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusMd),
                            ),
                            elevation: 0,
                            color: AppColors.primaryLight.withOpacity(0.2),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  member.name.isNotEmpty
                                      ? member.name[0].toUpperCase()
                                      : '?',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              title: Text(
                                member.name,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              subtitle: Text(
                                member.email,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (member.hasReceived)
                                    Container(
                                      padding: EdgeInsets.all(AppSpacing.xs),
                                      decoration: BoxDecoration(
                                        color:
                                            AppColors.success.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.check_circle,
                                        color: AppColors.success,
                                        size: 20,
                                      ),
                                    ),
                                  if (member.role == 'admin') ...[
                                    SizedBox(width: AppSpacing.sm),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm,
                                        vertical: AppSpacing.xs,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.info.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(
                                            AppSpacing.radiusSm),
                                      ),
                                      child: Text(
                                        'Admin',
                                        style:
                                            AppTextStyles.labelSmall.copyWith(
                                          color: AppColors.info,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.lg),

                // Boutons d'action (si admin)
                if (isAdmin)
                  Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomButton(
                          text: 'Créer contributions du round',
                          onPressed: group.members.isEmpty
                              ? () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Ajoutez des membres d\'abord'),
                                      backgroundColor: AppColors.warning,
                                    ),
                                  );
                                }
                              : () => _createRoundContributions(group),
                          type: ButtonType.primary,
                          icon: Icon(Icons.add_circle, color: Colors.white),
                        ),
                        SizedBox(height: AppSpacing.md),
                        CustomButton(
                          text: 'Passer au round suivant',
                          onPressed: () => _nextRound(group),
                          type: ButtonType.outline,
                          icon: Icon(Icons.navigate_next,
                              color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: AppSpacing.lg),
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
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      elevation: 0,
      color: valueColor?.withOpacity(0.3) ??
          AppColors.primaryLight.withOpacity(0.3),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: valueColor?.withOpacity(0.1) ??
                    AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(
                icon,
                color: valueColor ?? AppColors.primary,
                size: 24,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    value,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Color.lerp(
                          valueColor ?? AppColors.primary, Colors.black, 0.3)!,
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

  void _showAddMemberDialog(GroupModel group) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: Text(
          'Rejoindre le groupe',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width *
                0.9, // Augmente la largeur du modal
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nom',
                    hintText: 'Entrez votre nom',
                    prefixIcon: Icon(Icons.person, color: AppColors.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Entrez votre email',
                    prefixIcon: Icon(Icons.email, color: AppColors.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                ),
              ],
            ),
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Annuler',
                  onPressed: () => Navigator.pop(context),
                  type: ButtonType.outline,
                  fullWidth: true,
                ),
              ),
              SizedBox(width: AppSpacing.md), // Espacement entre les boutons
              Expanded(
                child: CustomButton(
                  text: 'Rejoindre',
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty ||
                        emailController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Veuillez remplir tous les champs'),
                          backgroundColor: AppColors.warning,
                        ),
                      );
                      return;
                    }

                    final currentUserId = _authService.currentUserId;

                    if (currentUserId == null || currentUserId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Vous devez être connecté'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }

                    print('📝 Ajout membre: userId=$currentUserId');

                    try {
                      await _groupService.addMember(
                        groupId: group.id,
                        userId: currentUserId,
                        name: nameController.text.trim(),
                        email: emailController.text.trim(),
                      );

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('✅ Vous avez rejoint le groupe !'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erreur: $e'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                  type: ButtonType.primary,
                  fullWidth: true,
                ),
              ),
            ],
          ),
        ],
        actionsPadding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ), // Padding pour les actions
      ),
    );
  }

  void _nextRound(GroupModel group) async {
    if (group.currentRound >= group.totalRounds) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Le groupe a terminé tous ses rounds'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    try {
      await _groupService.nextRound(groupId: group.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Round ${group.currentRound + 1} activé !'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _createRoundContributions(GroupModel group) async {
    if (group.members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ajoutez des membres avant de créer les contributions'),
          backgroundColor: AppColors.warning,
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
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
