import 'package:flutter/material.dart';

import '../data/loan_repository.dart';
import '../theme.dart';
import '../widgets/app_tab_bar.dart';
import '../widgets/loan_card.dart';
import 'new_loan_screen.dart';

/// Home / Active Loans screen (proposal, Section 2.A), laid out to match
/// the approved mockup: title, a dashed "N items out" summary pill, the
/// "Active Loans" section label, the card list, a glowing FAB, and the
/// bottom Active/History tab bar.
///
/// Tapping a card and the FAB are stubbed with a SnackBar until Week 2's
/// Feature 1 (Log an Item) and Feature 4 (Item Detail) are built.
class HomeScreen extends StatelessWidget {
  final LoanRepository repository;

  const HomeScreen({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
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

              final activeLoans = repository.active;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edge)
                    .copyWith(top: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ipahiram', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: AppSpacing.md),
                    _ItemsOutPill(count: activeLoans.length),
                    const SizedBox(height: AppSpacing.md),
                    Text('Active Loans', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Expanded(
                      child: activeLoans.isEmpty
                          ? Center(
                              child: Text(
                                'Nothing out right now.\nTap + to log a loan.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            )
                          : ListView.builder(
                              itemCount: activeLoans.length,
                              itemBuilder: (context, index) {
                                final loan = activeLoans[index];
                                return LoanCard(
                                  loan: loan,
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Item Detail screen — coming Week 2'),
                                      ),
                                    );
                                  },
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
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.45),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => NewLoanScreen(repository: repository),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
      bottomNavigationBar: AppTabBar(
        currentIndex: 0,
        onTabSelected: (index) {
          if (index == 1) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('History screen — coming Week 2/3')),
            );
          }
        },
      ),
    );
  }
}

/// The dashed-border "N items out" summary pill under the title.
class _ItemsOutPill extends StatelessWidget {
  final int count;

  const _ItemsOutPill({required this.count});

  @override
  Widget build(BuildContext context) {
    final label = count == 1 ? '1 item out' : '$count items out';

    return CustomPaint(
      painter: _DashedRRectPainter(color: AppColors.outline, radius: 24),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  final Color color;
  final double radius;

  _DashedRRectPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final dashPath = Path();
    const dashWidth = 5.0;
    const dashSpace = 4.0;

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        dashPath.addPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          Offset.zero,
        );
        distance = next + dashSpace;
      }
    }

    canvas.drawPath(
      dashPath,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) => false;
}
