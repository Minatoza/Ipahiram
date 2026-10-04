import 'package:flutter/material.dart';

import '../models/loan.dart';
import '../theme.dart';
import 'item_photo.dart';
import 'loan_status_badge.dart';

/// lib/widgets/loan_card.dart — Design System component #1.
/// Appears on: Home / Active Loans.
class LoanCard extends StatelessWidget {
  final Loan loan;
  final VoidCallback onTap;

  const LoanCard({super.key, required this.loan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        // Overdue loans get a colored left accent bar (drawn as a child
        // below) instead of a uniform border, matching the mockup.
        border: loan.isOverdue
            ? const Border(
                top: BorderSide(color: AppColors.outline),
                right: BorderSide(color: AppColors.outline),
                bottom: BorderSide(color: AppColors.outline),
              )
            : Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 72,
            decoration: BoxDecoration(
              color: loan.isOverdue ? AppColors.secondary : Colors.transparent,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: onTap,
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(14)),
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
                          Text('Lent to ${loan.borrower}',
                              style: textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.onSurfaceVariant)),
                          const SizedBox(height: 6),
                          LoanStatusBadge(loan: loan),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}