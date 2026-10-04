import 'package:flutter/material.dart';

import '../models/loan.dart';
import '../theme.dart';
import '../utils/format.dart';
import 'item_photo.dart';

/// A returned loan in the History list.
class HistoryCard extends StatelessWidget {
  final Loan loan;
  final VoidCallback onTap;

  const HistoryCard({super.key, required this.loan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              ItemPhoto(itemName: loan.itemName, photoBase64: loan.photoBase64),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loan.itemName, style: textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      'Lent to ${loan.borrower}',
                      style: textTheme.bodyMedium
                          ?.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Returned ${formatDate(loan.returnedAt!)} · '
                      'out ${formatDaysOut(loan.daysOut ?? 0)}',
                      style: textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}