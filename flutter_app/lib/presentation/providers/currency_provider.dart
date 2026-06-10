import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';

class CurrencyInfo {
  final String code;
  final String name;
  final String symbol;
  final double rate;

  const CurrencyInfo({
    required this.code,
    required this.name,
    required this.symbol,
    required this.rate,
  });
}

class CurrencyState {
  final String selectedCurrencyCode;
  final List<CurrencyInfo> currencies;

  const CurrencyState({
    this.selectedCurrencyCode = 'USD',
    this.currencies = const [],
  });

  CurrencyState copyWith({
    String? selectedCurrencyCode,
    List<CurrencyInfo>? currencies,
  }) {
    return CurrencyState(
      selectedCurrencyCode: selectedCurrencyCode ?? this.selectedCurrencyCode,
      currencies: currencies ?? this.currencies,
    );
  }

  CurrencyInfo? get selectedCurrency {
    try {
      return currencies.firstWhere((c) => c.code == selectedCurrencyCode);
    } catch (e) {
      return currencies.isNotEmpty ? currencies.first : null;
    }
  }

  double convertFromUsd(double usdAmount) {
    final currency = selectedCurrency;
    if (currency == null) return usdAmount;
    return usdAmount * currency.rate;
  }

  String formatAmount(double usdAmount) {
    final currency = selectedCurrency;
    if (currency == null) return '\$${usdAmount.toStringAsFixed(0)}';
    final converted = usdAmount * currency.rate;
    return _formatWithSymbol(converted, currency.symbol);
  }

  String _formatWithSymbol(double amount, String symbol) {
    final formatter = NumberFormat('#,##0', 'en_US');
    if (amount >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(2)}M';
    }
    return '$symbol${formatter.format(amount.round())}';
  }
}

class CurrencyNotifier extends StateNotifier<CurrencyState> {
  CurrencyNotifier() : super(const CurrencyState()) {
    _init();
  }

  Future<void> _init() async {
    final currencies = AppConstants.supportedCurrencies.map((c) {
      return CurrencyInfo(
        code: c['code'] as String,
        name: c['name'] as String,
        symbol: c['symbol'] as String,
        rate: (c['rate'] as num).toDouble(),
      );
    }).toList();

    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(AppConstants.keyCurrency) ?? 'USD';

    state = state.copyWith(
      currencies: currencies,
      selectedCurrencyCode: savedCode,
    );
  }

  Future<void> setCurrency(String code) async {
    state = state.copyWith(selectedCurrencyCode: code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyCurrency, code);
  }

  double getConversionRate(String fromCurrency) {
    try {
      final from = state.currencies.firstWhere((c) => c.code == fromCurrency);
      final to = state.selectedCurrency;
      if (to == null) return 1.0;
      // Convert through USD
      return to.rate / from.rate;
    } catch (e) {
      return 1.0;
    }
  }
}

final currencyProvider = StateNotifierProvider<CurrencyNotifier, CurrencyState>((ref) {
  return CurrencyNotifier();
});

// Helper provider for formatting
final formatCurrencyProvider = Provider.family<String, double>((ref, amount) {
  return ref.watch(currencyProvider).formatAmount(amount);
});
