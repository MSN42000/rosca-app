import 'package:flutter/material.dart';
import 'package:rosca_app/theme/app_spacing.dart';
import 'package:rosca_app/theme/app_text_style.dart';
import 'package:rosca_app/theme/app_theme.dart';
import '../models/group_model.dart';
import 'package:intl/intl.dart';

class GroupCard extends StatelessWidget {
  final GroupModel group;
  final VoidCallback? onTap;
  final bool showMembers;
  final bool showStatus;
  final bool showActions;

  const GroupCard({
    Key? key,
    required this.group,
    this.onTap,
    this.showMembers = true,
    this.showStatus = true,
    this.showActions = false,
  }) : super(key: key);

  Color _getStatusColor() {
    switch (group.status) {
      case 'active':
        return AppColors.secondary;
      case 'completed':
        return AppColors.info;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textDisabled;
    }
  }

  String _getStatusText() {
    switch (group.status) {
      case 'active':
        return 'Actif';
      case 'completed':
        return 'Terminé';
      case 'cancelled':
        return 'Annulé';
      default:
        return group.status;
    }
  }

  // Widget _buildMemberAvatars() {
  //   final activeMembers = group.members ?? [];
  //   if (activeMembers.isEmpty) return SizedBox.shrink();

  //   final displayMembers = activeMembers.take(3).toList();
  //   final remainingCount = activeMembers.length - 3;

  //   return Row(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       ...displayMembers.map(
  //         (member) => Container(
  //           margin: EdgeInsets.only(right: 4),
  //           child: CircleAvatar(
  //             radius: 14,
  //             backgroundColor: AppColors.primary,
  //             child: Text(
  //               member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
  //               style: TextStyle(
  //                 fontSize: 10,
  //                 color: AppColors.textSecondary,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //           ),
  //         ),
  //       ).toList(),
  //       if (remainingCount > 0)
  //         Container(
  //           margin: EdgeInsets.only(left: 4),
  //           child: CircleAvatar(
  //             radius: 14,
  //             backgroundColor: AppColors.primaryLight,
  //             child: Text(
  //               '+$remainingCount',
  //               style: TextStyle(
  //                 fontSize: 10,
  //                 color: AppColors.textSecondary,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //           ),
  //         ),
  //     ],
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '', decimalDigits: 0);
    final monthlyAmount = '${formatter.format(group.monthlyAmount)} MAD';
    final totalAmountPerRound =
        '${formatter.format(group.totalAmountPerRound)} MAD';
    final activeMembersCount = group.activeMembersCount;

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
                      child: Text(
                        group.name,
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8),
                    if (showStatus)
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                      'Mensuel',
                      monthlyAmount,
                      Icons.monetization_on_outlined,
                    ),
                    SizedBox(width: 16),
                    _buildInfoItem(
                      'Par Tour',
                      totalAmountPerRound,
                      Icons.account_balance_wallet_outlined,
                    ),
                    SizedBox(width: 16),
                    _buildInfoItem(
                      'Tour',
                      '${group.currentRound}/${group.totalRounds}',
                      Icons.repeat_outlined,
                    ),
                  ],
                ),

                // Section membres
                if (showMembers) ...[
                  SizedBox(height: 8),
                  Divider(color: AppColors.divider, height: 1),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Membres',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textDisabled,
                        ),
                      ),
                      SizedBox(width: 8),
                      // _buildMemberAvatars(),
                      SizedBox(width: 8),
                      Text(
                        '$activeMembersCount',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],

                // Actions
                if (showActions) ...[
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: onTap,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            backgroundColor:
                                AppColors.primaryLight.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Voir détails',
                            style: AppTextStyles.buttonMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      if (group.isActive) ...[
                        SizedBox(width: 8),
                        Expanded(
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.secondary,
                              backgroundColor:
                                  AppColors.secondaryLight.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Payer',
                              style: AppTextStyles.buttonMedium.copyWith(
                                color: AppColors.secondary,
                              ),
                            ),
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
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
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
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
