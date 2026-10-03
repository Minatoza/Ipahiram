import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/loan.dart';

/// Schedules a due-date reminder for each active loan, one notification per
/// loan id. No-ops entirely on web (proposal, Feature 3's kIsWeb guard) — the
/// computed `isOverdue` flag on Home is the fallback there.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (kIsWeb || _initialized) return;

    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.local);

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    _initialized = true;
  }

  /// Stable notification id derived from the loan id, so scheduling the
  /// same loan twice replaces rather than duplicates.
  int _idFor(String loanId) => loanId.hashCode & 0x7fffffff;

  Future<void> scheduleForLoan(Loan loan) async {
    if (kIsWeb || !loan.isActive) return;
    await init();

    final due = tz.TZDateTime.from(loan.dueDate, tz.local);
    if (due.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      _idFor(loan.id),
      'Ipahiram',
      '${loan.itemName} is due back from ${loan.borrower} today.',
      due,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'ipahiram_due_dates',
          'Due date reminders',
          channelDescription: 'Reminds you when a lent item is due back',
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelForLoan(String loanId) async {
    if (kIsWeb) return;
    await _plugin.cancel(_idFor(loanId));
  }

  /// Called once on launch (proposal: "reschedule from the saved list on
  /// launch") so reminders survive the app being closed and reopened.
  Future<void> rescheduleAll(List<Loan> allLoans) async {
    if (kIsWeb) return;
    await init();
    await _plugin.cancelAll();
    for (final loan in allLoans.where((l) => l.isActive)) {
      await scheduleForLoan(loan);
    }
  }
}