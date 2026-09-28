import 'package:flutter/material.dart';

import '../data/loan_repository.dart';
import '../widgets/app_tab_bar.dart';
import 'history_screen.dart';
import 'home_screen.dart';

/// Owns the bottom Active/History tab bar. IndexedStack keeps both tabs
/// alive, so scroll position survives switching.
class RootShell extends StatefulWidget {
  final LoanRepository repository;

  const RootShell({super.key, required this.repository});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(repository: widget.repository),
          HistoryScreen(repository: widget.repository),
        ],
      ),
      bottomNavigationBar: AppTabBar(
        currentIndex: _index,
        onTabSelected: (i) => setState(() => _index = i),
      ),
    );
  }
}