import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/contribution_model.dart';

class ContributionTile extends StatelessWidget {
  final ContributionModel contribution;
  final VoidCallback? onTap;
  final VoidCallback? onPayPressed;
  final VoidCallback? onApprovePressed;
  final bool isAdmin;

  const ContributionTile({
    Key? key,
    required this.contribution,
    this.onTap,
    this.onPayPressed,
    this.onApprovePressed,
    this.isAdmin = false,
  }) : super(key: key);

  Color _getStatusColor() {
    switch (contribution.status) {
      case 'approved':
        return Colors.green;
      case 'paid':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (contribution.status) {
      case 'approved':
        return 'Approuvée';
      case 'paid':
        return 'Payée';
      case 'pending':
        return 'En attente';
      case 'rejected':
        return 'Rejetée';
      default:
        return contribution.status.capitalize();
    }
  }

  IconData _getStatusIcon() {
    switch (contribution.status) {
      case 'approved':
        return Icons.check_circle;
      case 'paid':
        return Icons.payment;
      case 'pending':
        return Icons.pending;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '', decimalDigits: 2);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contribution.groupName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Round ${contribution.roundNumber}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColor().withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(),
                          size: 16,
                          color: _getStatusColor(),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getStatusText(),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getStatusColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Divider(height: 1, color: Colors.grey[300]),
              const SizedBox(height: 12),

              // Amount and due date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Montant',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${currencyFormat.format(contribution.amount)} MAD',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  if (contribution.dueDate != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Date limite',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat.format(contribution.dueDate!),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: contribution.isOverdue
                                ? Colors.red
                                : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              // Overdue warning
              if (contribution.isOverdue) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning,
                        size: 16,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Paiement en retard',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Paid date
              if (contribution.paidAt != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.blue, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Payée le ${dateFormat.format(contribution.paidAt!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],

              // Approved date
              if (contribution.approvedAt != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.verified, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Approuvée le ${dateFormat.format(contribution.approvedAt!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],

              // Actions
              if ((contribution.isPending || contribution.isPaid) &&
                  (onPayPressed != null || onApprovePressed != null)) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (contribution.isPending && onPayPressed != null)
                      Expanded(
                        child: _buildActionButton(
                          context: context,
                          text: 'Marquer comme payée',
                          color: Theme.of(context).primaryColor,
                          onPressed: onPayPressed!,
                        ),
                      ),
                    if (contribution.isPaid &&
                        onApprovePressed != null &&
                        isAdmin) ...[
                      if (contribution.isPending && onPayPressed != null)
                        const SizedBox(width: 8),
                      Expanded(
                        child: _buildActionButton(
                          context: context,
                          text: 'Approuver',
                          color: Colors.green,
                          onPressed: onApprovePressed!,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          elevation: 0,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}



/*
// lib/widgets/contribution_tile.dart
// lib/widgets/contribution_tile.dart

import 'package:flutter/material.dart';
import '../models/contribution_model.dart';
import 'package:intl/intl.dart';

class ContributionTile extends StatelessWidget {
  final ContributionModel contribution;
  final VoidCallback? onTap;
  final VoidCallback? onPayPressed;

  const ContributionTile({
    Key? key,
    required this.contribution,
    this.onTap,
    this.onPayPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getStatusColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec groupe et statut
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contribution.groupName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Round ${contribution.roundNumber}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(),
                ],
              ),
              SizedBox(height: 12),
              Divider(height: 1),
              SizedBox(height: 12),

              // Montant
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        color: Colors.green,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Montant',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${contribution.amount.toStringAsFixed(2)} MAD',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),

              // Date limite si présente
              if (contribution.dueDate != null) ...[
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          contribution.isOverdue
                              ? Icons.warning
                              : Icons.calendar_today,
                          color: contribution.isOverdue
                              ? Colors.red
                              : Colors.grey[600],
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Date limite',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      DateFormat('dd/MM/yyyy').format(contribution.dueDate!),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: contribution.isOverdue ? Colors.red : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],

              // Afficher les jours restants/en retard
              if (contribution.daysUntilDue != null && contribution.isPending) ...[
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: contribution.isOverdue
                        ? Colors.red.withOpacity(0.1)
                        : contribution.daysUntilDue! <= 3
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        contribution.isOverdue
                            ? Icons.error_outline
                            : Icons.info_outline,
                        size: 16,
                        color: contribution.isOverdue
                            ? Colors.red
                            : contribution.daysUntilDue! <= 3
                            ? Colors.orange
                            : Colors.blue,
                      ),
                      SizedBox(width: 4),
                      Text(
                        contribution.isOverdue
                            ? 'En retard de ${-contribution.daysUntilDue!} jour(s)'
                            : contribution.daysUntilDue == 0
                            ? 'À payer aujourd\'hui'
                            : '${contribution.daysUntilDue} jour(s) restant(s)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: contribution.isOverdue
                              ? Colors.red
                              : contribution.daysUntilDue! <= 3
                              ? Colors.orange
                              : Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Date de paiement si payée
              if (contribution.paidAt != null) ...[
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.blue, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Payée le ${DateFormat('dd/MM/yyyy').format(contribution.paidAt!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],

              // Date d'approbation si approuvée
              if (contribution.approvedAt != null) ...[
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.verified, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Approuvée le ${DateFormat('dd/MM/yyyy').format(contribution.approvedAt!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],

              // Bouton de paiement si en attente
              if (contribution.isPending && onPayPressed != null) ...[
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onPayPressed,
                    icon: Icon(Icons.payment, size: 18),
                    label: Text('Marquer comme payée'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    final statusColor = _getStatusColor();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(),
            size: 16,
            color: statusColor,
          ),
          SizedBox(width: 6),
          Text(
            _getStatusLabel(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (contribution.status) {
      case 'pending':
        return Colors.orange;
      case 'paid':
        return Colors.blue;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (contribution.status) {
      case 'pending':
        return Icons.pending;
      case 'paid':
        return Icons.payment;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _getStatusLabel() {
    switch (contribution.status) {
      case 'pending':
        return 'En attente';
      case 'paid':
        return 'Payée';
      case 'approved':
        return 'Approuvée';
      case 'rejected':
        return 'Rejetée';
      default:
        return contribution.status;
    }
  }
}

 */