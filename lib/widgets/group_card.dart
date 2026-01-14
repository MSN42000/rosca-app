import 'package:flutter/material.dart';
import 'package:rosca_app/theme/app_spacing.dart';
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

  Color _getStatusColor(BuildContext context) {
    switch (group.status) {
      case 'active':
        return Theme.of(context).colorScheme.primary;
      case 'completed':
        return Theme.of(context).colorScheme.secondary;
      case 'cancelled':
        return Theme.of(context).colorScheme.error;
      default:
        return Theme.of(context).colorScheme.onSurface.withOpacity(0.5);
    }
  }

  String _getStatusText() {
    switch (group.status) {
      case 'active':
        return 'Active';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return group.status;
    }
  }

  Widget _buildMemberAvatars(BuildContext context) {
    final activeMembers = group.members;
    final displayMembers = activeMembers.take(3);
    final remainingCount = activeMembers.length - 3;

    return Row(
      children: [
        ...displayMembers.map(
              (member) => Container(
            margin: const EdgeInsets.only(right: -8),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: Text(
                member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        if (remainingCount > 0)
          Container(
            margin: const EdgeInsets.only(left: 4),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              child: Text(
                '+$remainingCount',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final monthlyAmount = formatter.format(group.monthlyAmount);
    final totalAmountPerRound = formatter.format(group.totalAmountPerRound);
    final activeMembersCount = group.activeMembersCount;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      group.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (showStatus)
                    Chip(
                      label: Text(
                        _getStatusText(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: _getStatusColor(context),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoItem(
                    context,
                    'Monthly',
                    monthlyAmount,
                    Icons.monetization_on_outlined,
                  ),
                  const SizedBox(width: 16),
                  _buildInfoItem(
                    context,
                    'Per Round',
                    totalAmountPerRound,
                    Icons.account_balance_wallet_outlined,
                  ),
                  const SizedBox(width: 16),
                  _buildInfoItem(
                    context,
                    'Round',
                    '${group.currentRound}/${group.totalRounds}',
                    Icons.repeat_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (showMembers)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Members',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _buildMemberAvatars(context),
                              const SizedBox(width: 8),
                              Text(
                                '$activeMembersCount members',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  // if (group.isActive && group.currentReceiverId != null)
                  //   Container(
                  //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  //     decoration: BoxDecoration(
                  //       color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  //       borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  //     ),
                  //     child: Row(
                  //       mainAxisSize: MainAxisSize.min,
                  //       children: [
                  //         Icon(
                  //           Icons.person,
                  //           color: Theme.of(context).colorScheme.primary,
                  //           size: 14,
                  //         ),
                  //         const SizedBox(width: 4),
                  //         Text(
                  //           'Current Receiver',
                  //           style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  //             color: Theme.of(context).colorScheme.primary,
                  //             fontWeight: FontWeight.w600,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                ],
              ),
              if (showActions)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.primary,
                            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          ),
                          child: const Text('View Details'),
                        ),
                      ),
                      if (group.isActive)
                        const SizedBox(width: 8),
                      if (group.isActive)
                        Expanded(
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context).colorScheme.secondary,
                              backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                            ),
                            child: const Text('Make Payment'),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}