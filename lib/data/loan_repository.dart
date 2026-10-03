import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/loan.dart';

/// Everything the app knows about loans, and the only place that touches
/// storage. Screens listen to this with ListenableBuilder instead of
/// managing their own copies of the list.
///
/// Storage choice (from the proposal, section 5): shared_preferences,
/// one JSON-encoded list under the key 'ipahiram.loans.v1'. The version
/// suffix lets a future migration change the shape of Loan without
/// guessing at old data.
class LoanRepository extends ChangeNotifier {
  static const _storageKey = 'ipahiram.loans.v1';

  List<Loan> _loans = [];
  bool _isLoaded = false;

  List<Loan> get all => List.unmodifiable(_loans);

  /// Active loans, sorted by due date (soonest first), matching the
  /// Home / Active Loans screen spec.
  List<Loan> get active {
    final list = _loans.where((l) => l.isActive).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return list;
  }

  /// Returned loans, newest return first, matching the History screen spec.
  List<Loan> get history {
    final list = _loans.where((l) => !l.isActive).toList()
      ..sort((a, b) => b.returnedAt!.compareTo(a.returnedAt!));
    return list;
  }

  bool get isLoaded => _isLoaded;

  /// Loads the saved list from disk. Starts empty on a genuinely fresh
  /// install — no seeded sample data — so everything shown came from what
  /// the user actually typed into the New Loan form.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null) {
      _loans = [];
    } else {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _loans = decoded
            .map((e) => Loan.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        // Corrupt or unreadable data shouldn't crash the app on launch.
        _loans = [];
      }
    }

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_loans.map((l) => l.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  Future<void> addLoan(Loan loan) async {
    _loans = [..._loans, loan];
    notifyListeners();
    await _persist();
  }

  Future<void> updateLoan(
    String id, {
    required String itemName,
    required String borrower,
    required DateTime dueDate,
    String? note,
  }) async {
    _loans = _loans
        .map((l) => l.id == id
            ? l.copyWith(
                itemName: itemName,
                borrower: borrower,
                dueDate: dueDate,
                note: note,
                clearNote: note == null,
              )
            : l)
        .toList();
    notifyListeners();
    await _persist();
  }
  
  Future<void> markReturned(String id, {DateTime? returnedAt}) async {
    _loans = _loans
        .map((l) => l.id == id
            ? l.copyWith(returnedAt: returnedAt ?? DateTime.now())
            : l)
        .toList();
    notifyListeners();
    await _persist();
  }

  Future<void> extendDueDate(String id, DateTime newDueDate) async {
    _loans =
        _loans.map((l) => l.id == id ? l.copyWith(dueDate: newDueDate) : l).toList();
    notifyListeners();
    await _persist();
  }
}
