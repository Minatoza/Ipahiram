import 'package:flutter/material.dart';

import '../data/loan_repository.dart';
import '../theme.dart';
import '../widgets/history_card.dart';
import 'item_detail_screen.dart';

/// History tab: every returned loan, newest return first.
class HistoryScreen extends StatelessWidget {
  final LoanRepository repository;

  const HistoryScreen({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          bottom: false,
          child: ListenableBuilder(
            listenable: repository,
            builder: (context, _) {
              if (!repository.isLoaded) {
                return const Center(child: CircularProgressIndicator());
              }

              final returned = repository.history;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edge)
                    .copyWith(top: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('History', style: textTheme.headlineSmall),
                    const SizedBox(height: AppSpacing.md),
                    Text('Returned', style: textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Expanded(
                      child: returned.isEmpty
                          ? Center(
                              child: Text(
                                'No returned items yet.\n'
                                'Loans you mark returned show up here.',
                                textAlign: TextAlign.center,
                                style: textTheme.bodyMedium,
                              ),
                            )
                          : ListView.builder(
                              itemCount: returned.length,
                              itemBuilder: (context, index) {
                                final loan = returned[index];
                                return HistoryCard(
                                  loan: loan,
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ItemDetailScreen(
                                        repository: repository,
                                        loanId: loan.id,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
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