import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/contribution_model.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_style.dart';
import '../theme/app_theme.dart';

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
        return AppColors.success;
      case 'paid':
        return AppColors.info;
      case 'pending':
        return AppColors.warning;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText() {
    switch (contribution.status) {
      case 'approved':
        return 'Apprové';
      case 'paid':
        return 'Payé';
      case 'pending':
        return 'En attente';
      case 'rejected':
        return 'Rejeté';
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
    final dateFormat = DateFormat('MMM dd, yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: AppColors.card,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec nom et statut
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contribution.groupName,
                            style: AppTextStyles.titleLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Round ${contribution.roundNumber}',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textDisabled,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getStatusText(),
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Divider(color: AppColors.divider, height: 1),
                SizedBox(height: 8),

                // Informations financières
                Row(
                  children: [
                    _buildInfoItem(
                      'Amount',
                      currencyFormat.format(contribution.amount),
                      Icons.monetization_on_outlined,
                    ),
                    SizedBox(width: 16),
                    if (contribution.dueDate != null)
                      _buildInfoItem(
                        'Due Date',
                        dateFormat.format(contribution.dueDate!),
                        Icons.calendar_today_outlined,
                        valueColor: contribution.isOverdue
                            ? AppColors.error
                            : AppColors.textPrimary,
                      ),
                  ],
                ),

                // Overdue warning
                if (contribution.isOverdue) ...[
                  SizedBox(height: 8),
                  Divider(color: AppColors.divider, height: 1),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.warning,
                        size: 14,
                        color: AppColors.error,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Payment is overdue',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],

                // Actions
                if ((contribution.isPending || contribution.isPaid) &&
                    (onPayPressed != null || onApprovePressed != null)) ...[
                  SizedBox(height: 16),
                  Row(
                    children: [
                      if (contribution.isPending && onPayPressed != null)
                        Expanded(
                          child: TextButton(
                            onPressed: onPayPressed,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              backgroundColor:
                                  AppColors.primaryLight,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Payer',
                              style: AppTextStyles.buttonMedium.copyWith(
                                fontWeight: FontWeight.w400,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      if (contribution.isPending &&
                          onPayPressed != null &&
                          contribution.isPaid &&
                          onApprovePressed != null &&
                          isAdmin)
                        SizedBox(width: 8),
                      if (contribution.isPaid &&
                          onApprovePressed != null &&
                          isAdmin)
                        Expanded(
                          child: TextButton(
                            onPressed: onApprovePressed,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.success,
                              backgroundColor:
                                  AppColors.success.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Approve',
                              style: AppTextStyles.buttonMedium.copyWith(
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: AppColors.textDisabled,
              ),
              SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textDisabled,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
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