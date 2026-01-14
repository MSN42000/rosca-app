// lib/screens/contributions/my_contributions_screen.dart

import 'package:flutter/material.dart';
import 'package:rosca_app/screens/contributions/my_contributions_screen.dart';
import '../../models/contribution_model.dart';
import '../../services/contribution_service.dart';
import '../../services/auth_service.dart';
import 'package:intl/intl.dart';

class MyContributionsScreen extends StatefulWidget {
  @override
  _MyContributionsScreenState createState() => _MyContributionsScreenState();
}

class _MyContributionsScreenState extends State<MyContributionsScreen> {
  final ContributionService _contributionService = ContributionService();
  final AuthService _authService = AuthService();

  String _selectedFilter = 'all'; // all, pending, paid

  @override
  Widget build(BuildContext context) {
    final currentUserId = _authService.currentUserId;

    if (currentUserId == null) {
      return Scaffold(
        body: Center(child: Text('Vous devez être connecté')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Mes contributions'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'all', child: Text('Toutes')),
              PopupMenuItem(value: 'pending', child: Text('En attente')),
              PopupMenuItem(value: 'paid', child: Text('Payées')),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<ContributionModel>>(
        stream: _contributionService.getUserContributionsStream(currentUserId),
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
                  Icon(Icons.receipt_long, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Aucune contribution',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          var contributions = snapshot.data!;

          // Filtrer les contributions
          if (_selectedFilter != 'all') {
            contributions = contributions
                .where((c) => c.status == _selectedFilter)
                .toList();
          }

          // Calculer les statistiques
          final totalAmount = contributions
              .where((c) => c.isPaid)
              .fold(0.0, (sum, c) => sum + c.amount);
          final pendingCount = contributions.where((c) => c.isPending).length;

          return Column(
            children: [
              // Statistiques
              Container(
                padding: EdgeInsets.all(16),
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      label: 'Total payé',
                      value: '${totalAmount.toStringAsFixed(2)} MAD',
                      icon: Icons.attach_money,
                    ),
                    _buildStatCard(
                      label: 'En attente',
                      value: '$pendingCount',
                      icon: Icons.pending,
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),

              // Liste des contributions
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: contributions.length,
                  itemBuilder: (context, index) {
                    final contribution = contributions[index];
                    return _buildContributionCard(contribution);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    Color? color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color ?? Theme.of(context).primaryColor),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildContributionCard(ContributionModel contribution) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (contribution.isPending) {
      statusColor = Colors.orange;
      statusIcon = Icons.pending;
      statusText = 'En attente';
    } else {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'Payée';
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showContributionDetails(contribution),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Round ${contribution.roundNumber}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                '${contribution.amount.toStringAsFixed(2)} MAD',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              if (contribution.paidAt != null) ...[
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      'Payée le ${DateFormat('dd/MM/yyyy').format(contribution.paidAt!)}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showContributionDetails(ContributionModel contribution) {
    showModalBottomSheet(
      context: context,
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
              Text(
                'Détails de la contribution',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              _buildDetailRow('Montant',
                  '${contribution.amount.toStringAsFixed(2)} MAD'),
              _buildDetailRow('Round', '${contribution.roundNumber}'),
              _buildDetailRow('Statut', contribution.status),
              if (contribution.paidAt != null)
                _buildDetailRow('Payée le',
                    DateFormat('dd/MM/yyyy à HH:mm')
                        .format(contribution.paidAt!)),
              SizedBox(height: 16),
              if (contribution.isPending)
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _contributionService.markAsPaid(
                        contributionId: contribution.id,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Marquée comme payée !')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur: $e')),
                      );
                    }
                  },
                  child: Text('Marquer comme payée'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}