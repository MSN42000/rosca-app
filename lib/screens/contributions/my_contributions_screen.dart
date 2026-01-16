import 'package:flutter/material.dart';
import '../../models/contribution_model.dart';
import '../../services/contribution_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/contribution_tile.dart';
import '../../widgets/custom_appbar.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_style.dart';
import '../../theme/app_theme.dart';
import 'package:intl/intl.dart';

class MyContributionsScreen extends StatefulWidget {
  const MyContributionsScreen({Key? key}) : super(key: key);

  @override
  _MyContributionsScreenState createState() => _MyContributionsScreenState();
}

class _MyContributionsScreenState extends State<MyContributionsScreen> {
  final ContributionService _contributionService = ContributionService();
  final AuthService _authService = AuthService();

  String _selectedFilter = 'all'; // all, pending, paid, approved, rejected

  @override
  void initState() {
    super.initState();
    // _debugLoadContributions();
  }

  // Méthode de débogage pour vérifier les données
  // void _debugLoadContributions() async {
  //   final currentUserId = _authService.currentUserId;
  //   if (currentUserId != null) {
  //     print('🔍 DEBUG: UserId = $currentUserId');
  //     try {
  //       final contributions = await _contributionService.getUserContributions(currentUserId);
  //       print('🔍 DEBUG: Nombre de contributions trouvées: ${contributions.length}');
  //       for (var contrib in contributions) {
  //         print('🔍 DEBUG: Contribution - ID: ${contrib.id}, Amount: ${contrib.amount}, Status: ${contrib.status}');
  //       }
  //     } catch (e) {
  //       print('❌ DEBUG: Erreur lors du chargement: $e');
  //     }
  //   } else {
  //     print('❌ DEBUG: UserId est null');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _authService.currentUserId;

    // print('🔄 BUILD: currentUserId = $currentUserId');

    if (currentUserId == null || currentUserId.isEmpty) {
      return Scaffold(
        appBar: CustomAppBar(
          title: 'Mes contributions',
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off, size: 80, color: AppColors.textDisabled),
              SizedBox(height: AppSpacing.md),
              Text(
                'Vous devez être connecté',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textDisabled,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                ),
                child: Text('Se connecter'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Mes contributions',
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                // _debugLoadContributions();
              });
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list, color: Colors.white),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(Icons.list, size: 20, color: AppColors.primary),
                    SizedBox(width: AppSpacing.sm),
                    Text('Toutes', style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'pending',
                child: Row(
                  children: [
                    Icon(Icons.pending, size: 20, color: AppColors.warning),
                    SizedBox(width: AppSpacing.sm),
                    Text('En attente', style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'paid',
                child: Row(
                  children: [
                    Icon(Icons.payment, size: 20, color: AppColors.info),
                    SizedBox(width: AppSpacing.sm),
                    Text('Payées', style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'approved',
                child: Row(
                  children: [
                    Icon(Icons.check_circle,
                        size: 20, color: AppColors.success),
                    SizedBox(width: AppSpacing.sm),
                    Text('Approuvées', style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'rejected',
                child: Row(
                  children: [
                    Icon(Icons.cancel, size: 20, color: AppColors.error),
                    SizedBox(width: AppSpacing.sm),
                    Text('Rejetées', style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<ContributionModel>>(
        stream: _contributionService.getUserContributionsStream(currentUserId),
        builder: (context, snapshot) {
          // print('🔄 STREAM: connectionState = ${snapshot.connectionState}');
          // print('🔄 STREAM: hasData = ${snapshot.hasData}');
          // print('🔄 STREAM: hasError = ${snapshot.hasError}');
          // if (snapshot.hasData) {
          //   print('🔄 STREAM: data.length = ${snapshot.data!.length}');
          // }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'Chargement des contributions...',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            // print('❌ STREAM ERROR: ${snapshot.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: AppColors.error),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'Erreur de chargement',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: Text(
                      '${snapshot.error}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        // _debugLoadContributions();
                      });
                    },
                    icon: Icon(Icons.refresh),
                    label: Text('Réessayer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            );
          }

          // Vérification si les données sont nulles ou vides
          if (!snapshot.hasData || snapshot.data == null) {
            // print('⚠️ STREAM: snapshot.data est null');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long,
                      size: 80, color: AppColors.textDisabled),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'Aucune contribution',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textDisabled,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Vos contributions apparaîtront ici',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textDisabled,
                    ),
                  ),
                ],
              ),
            );
          }

          var contributions = snapshot.data!;

          if (contributions.isEmpty) {
            // print('⚠️ STREAM: Liste de contributions vide');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long,
                      size: 80, color: AppColors.textDisabled),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'Aucune contribution trouvée',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textDisabled,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Les contributions de votre groupe\napparaîtront ici',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textDisabled,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.md),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        // _debugLoadContributions();
                      });
                    },
                    icon: Icon(Icons.refresh, color: AppColors.primary),
                    label: Text('Actualiser'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            );
          }

          // print('✅ STREAM: ${contributions.length} contributions trouvées');

          // Filtrer les contributions
          List<ContributionModel> filteredContributions = contributions;
          if (_selectedFilter != 'all') {
            filteredContributions = contributions
                .where((c) => c.status == _selectedFilter)
                .toList();
            // print('🔍 FILTER: ${filteredContributions.length} contributions après filtre "$_selectedFilter"');
          }

          // Calculer les statistiques
          final totalApproved = contributions
              .where((c) => c.isApproved)
              .fold<double>(0.0, (sum, c) => sum + c.amount);
          final pendingCount = contributions.where((c) => c.isPending).length;
          final paidCount = contributions.where((c) => c.isPaid).length;
          final approvedCount = contributions.where((c) => c.isApproved).length;
          final overdueCount = contributions.where((c) => c.isOverdue).length;

          return filteredContributions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox,
                          size: 80, color: AppColors.textDisabled),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        'Aucune contribution ${_getFilterLabel(_selectedFilter).toLowerCase()}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textDisabled,
                        ),
                      ),
                    ],
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    // Statistiques - Style uniforme avec group_details
                    SliverToBoxAdapter(
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    label: 'Total approuvé',
                                    value:
                                        '${totalApproved.toStringAsFixed(2)} MAD',
                                    icon: Icons.check_circle,
                                    color: AppColors.success,
                                  ),
                                ),
                                SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: _buildStatCard(
                                    label: 'Approuvées',
                                    value: '$approvedCount',
                                    icon: Icons.verified,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    label: 'En attente',
                                    value: '$pendingCount',
                                    icon: Icons.pending,
                                    color: AppColors.warning,
                                  ),
                                ),
                                SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: _buildStatCard(
                                    label: 'Payées',
                                    value: '$paidCount',
                                    icon: Icons.payment,
                                    color: AppColors.info,
                                  ),
                                ),
                              ],
                            ),
                            if (overdueCount > 0) ...[
                              SizedBox(height: AppSpacing.sm),
                              Container(
                                padding: EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusMd),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.warning,
                                        color: Colors.white, size: 20),
                                    SizedBox(width: AppSpacing.sm),
                                    Text(
                                      '$overdueCount contribution(s) en retard',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Indicateur de filtre actif
                    if (_selectedFilter != 'all')
                      SliverToBoxAdapter(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: AppSpacing.sm,
                            horizontal: AppSpacing.md,
                          ),
                          color: AppColors.primaryLight.withOpacity(0.2),
                          child: Row(
                            children: [
                              Icon(Icons.filter_alt,
                                  size: 16, color: AppColors.primary),
                              SizedBox(width: AppSpacing.sm),
                              Text(
                                'Filtre: ${_getFilterLabel(_selectedFilter)} (${filteredContributions.length})',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Spacer(),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedFilter = 'all';
                                  });
                                },
                                child: Text(
                                  'Tout afficher',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Liste des contributions
                    SliverPadding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final contribution = filteredContributions[index];
                            return ContributionTile(
                              contribution: contribution,
                              onTap: () =>
                                  _showContributionDetails(contribution),
                              onPayPressed: contribution.isPending
                                  ? () => _handlePayContribution(contribution)
                                  : null,
                            );
                          },
                          childCount: filteredContributions.length,
                        ),
                      ),
                    ),
                  ],
                );
        },
      ),
    );
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'pending':
        return 'En attente';
      case 'paid':
        return 'Payées';
      case 'approved':
        return 'Approuvées';
      case 'rejected':
        return 'Rejetées';
      default:
        return 'Toutes';
    }
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    Color? color,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.card, size: 28),
          SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.card,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handlePayContribution(ContributionModel contribution) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: Text(
          'Confirmer le paiement',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Voulez-vous marquer cette contribution de ${contribution.amount.toStringAsFixed(2)} MAD comme payée ?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          // TextButton(
          //   onPressed: () => Navigator.pop(context, false),
          //   style: TextButton.styleFrom(
          //     // foregroundColor: AppColors.primary,
          //     backgroundColor: AppColors.primaryLight,
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //   ),
          //   child: Text(
          //     'Annuler',
          //     style: TextStyle(color: AppColors.primary),
          //   ),
          // ),
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              foregroundColor: AppColors.primary,
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Confirmer',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _contributionService.markAsPaid(
          contributionId: contribution.id,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Contribution marquée comme payée !'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        // print('❌ ERROR markAsPaid: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showContributionDetails(ContributionModel contribution) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.receipt_long,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Détails de la contribution',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Divider(height: AppSpacing.lg),
              // _buildDetailRow('ID', contribution.id),
              _buildDetailRow('Groupe', contribution.groupName),
              _buildDetailRow('Round', '${contribution.roundNumber}'),
              _buildDetailRow(
                'Montant',
                '${contribution.amount.toStringAsFixed(2)} MAD',
              ),
              _buildDetailRow('Statut', _getStatusLabel(contribution.status)),
              if (contribution.dueDate != null)
                _buildDetailRow(
                  'Date limite',
                  DateFormat('dd/MM/yyyy').format(contribution.dueDate!),
                ),
              if (contribution.paidAt != null)
                _buildDetailRow(
                  'Payée le',
                  DateFormat('dd/MM/yyyy à HH:mm').format(contribution.paidAt!),
                ),
              if (contribution.approvedAt != null)
                _buildDetailRow(
                  'Approuvée le',
                  DateFormat('dd/MM/yyyy à HH:mm')
                      .format(contribution.approvedAt!),
                ),
              if (contribution.approvedBy != null)
                _buildDetailRow('Approuvée par', contribution.approvedBy!),
              SizedBox(height: AppSpacing.md),
              if (contribution.isPending)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _handlePayContribution(contribution);
                    },
                    icon: Icon(Icons.payment),
                    label: Text(
                      'Marquer comme payée',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.card,
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'paid':
        return 'Payée';
      case 'approved':
        return 'Approuvée';
      case 'rejected':
        return 'Rejetée';
      default:
        return status;
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
