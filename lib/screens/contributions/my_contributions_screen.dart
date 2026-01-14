// lib/screens/contributions/my_contributions_screen.dart

import 'package:flutter/material.dart';
import '../../models/contribution_model.dart';
import '../../services/contribution_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/contribution_tile.dart';
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
    _debugLoadContributions();
  }

  // Méthode de débogage pour vérifier les données
  void _debugLoadContributions() async {
    final currentUserId = _authService.currentUserId;
    if (currentUserId != null) {
      print('🔍 DEBUG: UserId = $currentUserId');
      try {
        final contributions = await _contributionService.getUserContributions(currentUserId);
        print('🔍 DEBUG: Nombre de contributions trouvées: ${contributions.length}');
        for (var contrib in contributions) {
          print('🔍 DEBUG: Contribution - ID: ${contrib.id}, Amount: ${contrib.amount}, Status: ${contrib.status}');
        }
      } catch (e) {
        print('❌ DEBUG: Erreur lors du chargement: $e');
      }
    } else {
      print('❌ DEBUG: UserId est null');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _authService.currentUserId;

    print('🔄 BUILD: currentUserId = $currentUserId');

    if (currentUserId == null || currentUserId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Mes contributions'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Vous devez être connecté',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Retour à l'écran de connexion
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                child: Text('Se connecter'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Mes contributions'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _debugLoadContributions();
              });
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(Icons.list, size: 20),
                    SizedBox(width: 12),
                    Text('Toutes'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'pending',
                child: Row(
                  children: [
                    Icon(Icons.pending, size: 20, color: Colors.orange),
                    SizedBox(width: 12),
                    Text('En attente'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'paid',
                child: Row(
                  children: [
                    Icon(Icons.payment, size: 20, color: Colors.blue),
                    SizedBox(width: 12),
                    Text('Payées'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'approved',
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 20, color: Colors.green),
                    SizedBox(width: 12),
                    Text('Approuvées'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'rejected',
                child: Row(
                  children: [
                    Icon(Icons.cancel, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Rejetées'),
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
          print('🔄 STREAM: connectionState = ${snapshot.connectionState}');
          print('🔄 STREAM: hasData = ${snapshot.hasData}');
          print('🔄 STREAM: hasError = ${snapshot.hasError}');
          if (snapshot.hasData) {
            print('🔄 STREAM: data.length = ${snapshot.data!.length}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Chargement des contributions...'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            print('❌ STREAM ERROR: ${snapshot.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Erreur de chargement',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      '${snapshot.error}',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _debugLoadContributions();
                      });
                    },
                    icon: Icon(Icons.refresh),
                    label: Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          // Vérification si les données sont nulles ou vides
          if (!snapshot.hasData || snapshot.data == null) {
            print('⚠️ STREAM: snapshot.data est null');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Aucune contribution',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Vos contributions apparaîtront ici',
                    style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'UserId: $currentUserId',
                    style: TextStyle(fontSize: 10, color: Colors.grey[300]),
                  ),
                ],
              ),
            );
          }

          var contributions = snapshot.data!;

          if (contributions.isEmpty) {
            print('⚠️ STREAM: Liste de contributions vide');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Aucune contribution trouvée',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Les contributions de votre groupe apparaîtront ici',
                    style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _debugLoadContributions();
                      });
                    },
                    icon: Icon(Icons.refresh),
                    label: Text('Actualiser'),
                  ),
                ],
              ),
            );
          }

          print('✅ STREAM: ${contributions.length} contributions trouvées');

          // Filtrer les contributions
          List<ContributionModel> filteredContributions = contributions;
          if (_selectedFilter != 'all') {
            filteredContributions = contributions
                .where((c) => c.status == _selectedFilter)
                .toList();
            print('🔍 FILTER: ${filteredContributions.length} contributions après filtre "$_selectedFilter"');
          }

          // Calculer les statistiques
          final totalApproved = contributions
              .where((c) => c.isApproved)
              .fold<double>(0.0, (sum, c) => sum + c.amount);
          final pendingCount = contributions.where((c) => c.isPending).length;
          final paidCount = contributions.where((c) => c.isPaid).length;
          final approvedCount = contributions.where((c) => c.isApproved).length;
          final overdueCount = contributions.where((c) => c.isOverdue).length;

          return Column(
            children: [
              // Statistiques
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.1),
                      Theme.of(context).primaryColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard(
                          label: 'Total approuvé',
                          value: '${totalApproved.toStringAsFixed(2)} MAD',
                          icon: Icons.check_circle,
                          color: Colors.green,
                        ),
                        _buildStatCard(
                          label: 'Approuvées',
                          value: '$approvedCount',
                          icon: Icons.verified,
                          color: Colors.green,
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard(
                          label: 'En attente',
                          value: '$pendingCount',
                          icon: Icons.pending,
                          color: Colors.orange,
                        ),
                        _buildStatCard(
                          label: 'Payées',
                          value: '$paidCount',
                          icon: Icons.payment,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                    if (overdueCount > 0) ...[
                      SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.warning, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text(
                              '$overdueCount contribution(s) en retard',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Indicateur de filtre actif
              if (_selectedFilter != 'all')
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Row(
                    children: [
                      Icon(Icons.filter_alt, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Filtre: ${_getFilterLabel(_selectedFilter)} (${filteredContributions.length})',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Spacer(),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedFilter = 'all';
                          });
                        },
                        child: Text('Tout afficher'),
                      ),
                    ],
                  ),
                ),

              // Liste des contributions
              Expanded(
                child: filteredContributions.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Aucune contribution ${_getFilterLabel(_selectedFilter).toLowerCase()}',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${contributions.length} contribution(s) au total',
                        style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: filteredContributions.length,
                  itemBuilder: (context, index) {
                    final contribution = filteredContributions[index];
                    return ContributionTile(
                      contribution: contribution,
                      onTap: () => _showContributionDetails(contribution),
                      onPayPressed: contribution.isPending
                          ? () => _handlePayContribution(contribution)
                          : null,
                    );
                  },
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
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color ?? Theme.of(context).primaryColor, size: 28),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color ?? Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handlePayContribution(ContributionModel contribution) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmer le paiement'),
        content: Text(
          'Voulez-vous marquer cette contribution de ${contribution.amount.toStringAsFixed(2)} MAD comme payée ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Confirmer'),
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
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        print('❌ ERROR markAsPaid: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.receipt_long,
                    color: Theme.of(context).primaryColor,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Détails de la contribution',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Divider(height: 24),
              _buildDetailRow('ID', contribution.id),
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
              SizedBox(height: 16),
              if (contribution.isPending)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _handlePayContribution(contribution);
                    },
                    icon: Icon(Icons.payment),
                    label: Text('Marquer comme payée'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
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
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 15,
            ),
          ),
          SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}