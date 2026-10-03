/// A single lending record.
///
/// One Loan represents the whole lifecycle of an item going out and coming
/// back: `returnedAt == null` means it is still Active; setting `returnedAt`
/// is what makes it show up in History. There are deliberately two lists
/// (Active, History) but only ever one model — see the Design decision log
/// in the project proposal, section "Loan Model".
class Loan {
  final String id;
  final String itemName;
  final String borrower;
  final DateTime dateLent;
  final DateTime dueDate;
  final String? note;
  final DateTime? returnedAt;

  const Loan({
    required this.id,
    required this.itemName,
    required this.borrower,
    required this.dateLent,
    required this.dueDate,
    this.note,
    this.returnedAt,
  });

  /// True while the loan has not been marked returned.
  bool get isActive => returnedAt == null;

  /// True only for active loans whose due date has passed.
  /// This is the "computed overdue flag" the proposal relies on as the
  /// safety net when local notifications aren't available (web builds).
  bool get isOverdue => isActive && dueDate.isBefore(DateTime.now());

  /// How many whole days the item was out, once returned. Null while active.
  int? get daysOut {
    if (returnedAt == null) return null;
    return returnedAt!.difference(dateLent).inDays;
  }

   Loan copyWith({
    String? itemName,
    String? borrower,
    DateTime? dateLent,
    DateTime? dueDate,
    String? note,
    bool clearNote = false,
    DateTime? returnedAt,
  }) {
    return Loan(
      id: id,
      itemName: itemName ?? this.itemName,
      borrower: borrower ?? this.borrower,
      dateLent: dateLent ?? this.dateLent,
      dueDate: dueDate ?? this.dueDate,
      note: note ?? this.note,
      returnedAt: returnedAt ?? this.returnedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'itemName': itemName,
        'borrower': borrower,
        'dateLent': dateLent.toIso8601String(),
        'dueDate': dueDate.toIso8601String(),
        'note': note,
        'returnedAt': returnedAt?.toIso8601String(),
      };

  factory Loan.fromJson(Map<String, dynamic> json) => Loan(
        id: json['id'] as String,
        itemName: json['itemName'] as String,
        borrower: json['borrower'] as String,
        dateLent: DateTime.parse(json['dateLent'] as String),
        dueDate: DateTime.parse(json['dueDate'] as String),
        note: json['note'] as String?,
        returnedAt: json['returnedAt'] == null
            ? null
            : DateTime.parse(json['returnedAt'] as String),
      );
}
