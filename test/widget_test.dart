import 'package:final_project/models/loan.dart';
import 'package:final_project/theme.dart';
import 'package:final_project/widgets/loan_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Loan _loan({required DateTime due, DateTime? returnedAt}) => Loan(
      id: '1',
      itemName: 'Drill',
      borrower: 'Marco',
      dateLent: DateTime.now().subtract(const Duration(days: 10)),
      dueDate: due,
      returnedAt: returnedAt,
    );

void main() {
  group('Loan', () {
    test('active loan past its due date is overdue', () {
      final loan = _loan(due: DateTime.now().subtract(const Duration(days: 1)));
      expect(loan.isOverdue, isTrue);
    });

    test('returned loan is never overdue and reports days out', () {
      final loan = _loan(
        due: DateTime.now().subtract(const Duration(days: 1)),
        returnedAt: DateTime.now(),
      );
      expect(loan.isActive, isFalse);
      expect(loan.isOverdue, isFalse);
      expect(loan.daysOut, 10);
    });

    test('survives a JSON round trip', () {
      final loan = _loan(due: DateTime.now().add(const Duration(days: 3)));
      final copy = Loan.fromJson(loan.toJson());
      expect(copy.id, loan.id);
      expect(copy.dueDate, loan.dueDate);
      expect(copy.returnedAt, isNull);
    });
  });

  testWidgets('status badge shows Overdue for a late loan', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: appTheme,
      home: Scaffold(
        body: LoanStatusBadge(
          loan: _loan(due: DateTime.now().subtract(const Duration(days: 2))),
        ),
      ),
    ));

    expect(find.text('Overdue'), findsOneWidget);
  });
}