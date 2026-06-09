import 'package:intl/intl.dart';

class Formatters {
  static String currency(double amount, String currencyCode, {String? symbol}) {
    final formatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: symbol ?? '',
      decimalDigits: 0,
    );
    return '${symbol ?? currencyCode} ${formatter.format(amount).trim()}';
  }

  static String number(num value, {int decimals = 0}) {
    final formatter = NumberFormat('#,###${decimals > 0 ? '.' + '0' * decimals : ''}');
    return formatter.format(value);
  }

  static String area(double sqft, {bool showBoth = false}) {
    final sqm = sqft / 10.764;
    if (showBoth) return '${number(sqft)} sq ft (${number(sqm, decimals: 1)} sq m)';
    return '${number(sqft)} sq ft';
  }

  static String date(DateTime? dt) {
    if (dt == null) return '-';
    return DateFormat('MMM d, yyyy').format(dt);
  }

  static String relativeDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }

  static String fileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
