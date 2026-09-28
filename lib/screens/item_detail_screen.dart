import 'package:flutter/material.dart';

import '../data/loan_repository.dart';
import '../models/loan.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/loan_status_badge.dart';

/// Item Detail (proposal, Feature 4). Looks the loan up by id and listens to
/// the repository, so it always shows current data (e.g. after extending).
/// Returned loans open read-only: no action buttons.
class ItemDetailScreen extends StatelessWidget {
  final LoanRepository repository;
  final String loanId;

  const ItemDetailScreen({
    super.key,
    required this.repository,
    required this.loanId,
  });

  Future<void> _extend(BuildContext context, Loan loan) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initial = loan.dueDate.isAfter(today) ? loan.dueDate : today;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today,
      lastDate: initial.add(const Duration(days: 730)),
      helpText: 'New due date',
    );
    if (picked == null) return;

    await repository.extendDueDate(loan.id, picked);
  }

  Future<void> _markReturned(BuildContext context, Loan loan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Mark as returned?'),
        content: Text('${loan.borrower} gave back ${loan.itemName}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Returned'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    await repository.markReturned(loan.id);

    if (!context.mounted) return;
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(content: Text('${loan.itemName} moved to History')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          child: ListenableBuilder(
            listenable: repository,
            builder: (context, _) {
              final matches = repository.all.where((l) => l.id == loanId);
              final loan = matches.isEmpty ? null : matches.first;

              return Padding(
                padding: const EdgeInsets.all(AppSpacing.edge),
                child: ListView(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back,
                              color: AppColors.onSurface),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            loan?.itemName ?? 'Item',
                            style: textTheme.headlineSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (loan == null)
                      Text('This loan no longer exists.',
                          style: textTheme.bodyMedium)
                    else ...[
                      if (loan.isActive) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: LoanStatusBadge(loan: loan),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      _DetailCard(loan: loan),
                      const SizedBox(height: AppSpacing.edge),
                      if (loan.isActive) ...[
                        FilledButton(
                          onPressed: () => _markReturned(context, loan),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: const Text('Mark as Returned'),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        OutlinedButton(
                          onPressed: () => _extend(context, loan),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                          ),
                          child: const Text('Extend due date'),
                        ),
                      ],
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final Loan loan;

  const _DetailCard({required this.loan});

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[
      ('Lent to', loan.borrower),
      ('Date lent', formatDate(loan.dateLent)),
      ('Due', formatDate(loan.dueDate)),
      if (loan.returnedAt != null) ('Returned', formatDate(loan.returnedAt!)),
      if (loan.daysOut != null) ('Days out', formatDaysOut(loan.daysOut!)),
      if (loan.note != null) ('Note', loan.note!),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(color: AppColors.outline, height: AppSpacing.md * 2),
            _DetailRow(label: rows[i].$1, value: rows[i].$2),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 90, child: Text(label, style: textTheme.labelSmall)),
        Expanded(child: Text(value, style: textTheme.bodyMedium)),
      ],
    );
  }
}