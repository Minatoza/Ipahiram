import 'package:flutter/material.dart';

import '../models/loan.dart';
import '../theme.dart';

/// lib/widgets/loan_status_badge.dart — Design System component #6.
/// Appears on: Home / Active Loans, Item Detail.
///
/// The Design System doc specced this as a plain `bool isOverdue` badge,
/// but the mockup shows three states (Overdue / Due today / Due in Nd), so
/// this takes the whole `Loan` and derives the label from its due date —
/// noted here the same way the doc itself tracks "what changed and why".
class LoanStatusBadge extends StatelessWidget {
  final Loan loan;

  const LoanStatusBadge({super.key, required this.loan});

  @override
  Widget build(BuildContext context) {
    final status = _status(loan);
    final textStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: status.filled ? AppColors.onPrimary : AppColors.onSurfaceVariant,
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: status.filled ? AppColors.secondary : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: status.filled
            ? null
            : Border.all(color: AppColors.outline),
      ),
      child: Text(status.label, style: textStyle),
    );
  }

  _BadgeStatus _status(Loan loan) {
    if (loan.isOverdue) {
      return const _BadgeStatus('Overdue', filled: true);
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(loan.dueDate.year, loan.dueDate.month, loan.dueDate.day);
    final daysUntil = due.difference(today).inDays;

    if (daysUntil <= 0) {
      return const _BadgeStatus('Due today', filled: true);
    }
    return _BadgeStatus('Due in ${daysUntil}d', filled: false);
  }
}

class _BadgeStatus {
  final String label;
  final bool filled;
  const _BadgeStatus(this.label, {required this.filled});
}
