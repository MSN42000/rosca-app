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
        return 'Approved';
      case 'paid':
        return 'Paid';
      case 'pending':
        return 'Pending';
      case 'rejected':
        return 'Rejected';
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

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: BorderSide(
          color: AppColors.border,
          width: 1,
        ),
      ),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contribution.groupName,
                        style: TextStyles.titleMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Round ${contribution.roundNumber}',
                        style: TextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
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
                          size: AppSpacing.iconSm,
                          color: _getStatusColor(),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          _getStatusText(),
                          style: TextStyles.labelMedium.copyWith(
                            color: _getStatusColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Amount and due date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amount',
                        style: TextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        currencyFormat.format(contribution.amount),
                        style: TextStyles.amountM.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  if (contribution.dueDate != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Due Date',
                          style: TextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          dateFormat.format(contribution.dueDate!),
                          style: TextStyles.bodyM.copyWith(
                            fontWeight: FontWeight.w500,
                            color: contribution.isOverdue
                                ? AppColors.error
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              // Overdue warning
              if (contribution.isOverdue) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning,
                        size: AppSpacing.iconSm,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Payment is overdue',
                          style: TextStyles.bodySmall.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Actions
              if ((contribution.isPending || contribution.isPaid) &&
                  (onPayPressed != null || onApprovePressed != null)) ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    if (contribution.isPending && onPayPressed != null)
                      Expanded(
                        child: _buildActionButton(
                          context: context,
                          text: 'Pay Now',
                          color: AppColors.primary,
                          onPressed: (){},
                        ),
                      ),
                    if (contribution.isPaid && onApprovePressed != null && isAdmin)
                      Expanded(
                        child: _buildActionButton(
                          context: context,
                          text: 'Approve',
                          color: AppColors.success,
                          onPressed: (){},
                        ),
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

  Widget _buildActionButton({
    required BuildContext context,
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 36,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          elevation: 0,
        ),
        child: Text(
          text,
          style: TextStyles.label.copyWith(
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