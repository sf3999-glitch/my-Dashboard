import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(double amount, String currencyCode, String symbol) {
    if (amount >= 1000000) {
      final millions = amount / 1000000;
      return '$symbol${millions.toStringAsFixed(2)}M';
    }
    if (amount >= 1000) {
      final formatter = NumberFormat('#,##0', 'en_US');
      return '$symbol${formatter.format(amount.round())}';
    }
    return '$symbol${amount.toStringAsFixed(0)}';
  }

  static String formatCompact(double amount, String symbol) {
    if (amount >= 1000000000) {
      return '$symbol${(amount / 1000000000).toStringAsFixed(1)}B';
    }
    if (amount >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '$symbol${amount.toStringAsFixed(0)}';
  }
}

class NumberFormatter {
  NumberFormatter._();

  static String format(double value, {int decimals = 2}) {
    return NumberFormat('#,##0.${'0' * decimals}', 'en_US').format(value);
  }

  static String formatInt(int value) {
    return NumberFormat('#,##0', 'en_US').format(value);
  }

  static String formatArea(double value, String unit) {
    final formatted = NumberFormat('#,##0', 'en_US').format(value.round());
    return '$formatted $unit';
  }
}

class DateFormatter {
  DateFormatter._();

  static String formatShort(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatLong(DateTime date) {
    return DateFormat('MMMM d, yyyy').format(date);
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        if (diff.inMinutes == 0) return 'Just now';
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    }
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} months ago';
    return DateFormat('MMM d, yyyy').format(date);
  }

  static String formatForReport(DateTime date) {
    return DateFormat('MMMM d, yyyy • h:mm a').format(date);
  }
}

class AreaFormatter {
  AreaFormatter._();

  static double feetToMeters(double feet) => feet * 0.3048;
  static double metersToFeet(double meters) => meters / 0.3048;
  static double sqFtToSqM(double sqFt) => sqFt * 0.0929;
  static double sqMToSqFt(double sqM) => sqM / 0.0929;

  static String formatWithUnit(double value, String unit) {
    return '${NumberFormat('#,##0', 'en_US').format(value.round())} $unit';
  }
}
