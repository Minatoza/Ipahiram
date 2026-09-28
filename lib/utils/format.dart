const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// "Sep 24, 2026" — shared by Item Detail and History.
String formatDate(DateTime d) => '${_months[d.month - 1]} ${d.day}, ${d.year}';

/// "Same day", "1 day", "5 days".
String formatDaysOut(int days) {
  if (days <= 0) return 'Same day';
  return days == 1 ? '1 day' : '$days days';
}