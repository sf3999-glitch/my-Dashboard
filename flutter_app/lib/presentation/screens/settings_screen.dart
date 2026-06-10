import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() => _appVersion = info.version);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final currencyState = ref.watch(currencyProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Appearance
          _sectionHeader(context, l10n.appearance),
          _settingsTile(
            context: context,
            icon: Icons.palette_rounded,
            title: 'Theme',
            subtitle: _themeLabel(themeMode, l10n),
            colorScheme: colorScheme,
            onTap: () => _showThemeDialog(context, l10n, themeMode),
            trailing: _themeIcon(themeMode),
          ),
          const Divider(indent: 72, endIndent: 20),

          // Language
          _sectionHeader(context, 'Localization'),
          _settingsTile(
            context: context,
            icon: Icons.language_rounded,
            title: l10n.language,
            subtitle: _languageName(locale.languageCode),
            colorScheme: colorScheme,
            onTap: () => _showLanguageDialog(context, l10n, locale.languageCode),
            trailing: Text(
              _languageFlag(locale.languageCode),
              style: const TextStyle(fontSize: 24),
            ),
          ),
          const Divider(indent: 72, endIndent: 20),
          _settingsTile(
            context: context,
            icon: Icons.currency_exchange_rounded,
            title: l10n.currency,
            subtitle: currencyState.selectedCurrencyCode,
            colorScheme: colorScheme,
            onTap: () => _showCurrencyDialog(context, l10n, currencyState),
            trailing: Text(
              currencyState.selectedCurrency?.symbol ?? '\$',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),

          // Account
          _sectionHeader(context, l10n.account),
          _settingsTile(
            context: context,
            icon: Icons.person_outline_rounded,
            title: l10n.profile,
            subtitle: 'Manage your profile',
            colorScheme: colorScheme,
            onTap: () => context.push(AppRoutes.profile),
          ),

          // About
          _sectionHeader(context, l10n.about),
          _settingsTile(
            context: context,
            icon: Icons.info_outline_rounded,
            title: l10n.appVersion,
            subtitle: 'v$_appVersion',
            colorScheme: colorScheme,
          ),
          const Divider(indent: 72, endIndent: 20),
          _settingsTile(
            context: context,
            icon: Icons.description_outlined,
            title: l10n.termsOfService,
            colorScheme: colorScheme,
            onTap: () {},
          ),
          const Divider(indent: 72, endIndent: 20),
          _settingsTile(
            context: context,
            icon: Icons.privacy_tip_outlined,
            title: l10n.privacyPolicy,
            colorScheme: colorScheme,
            onTap: () {},
          ),
          const Divider(indent: 72, endIndent: 20),
          _settingsTile(
            context: context,
            icon: Icons.star_outline_rounded,
            title: l10n.rateApp,
            colorScheme: colorScheme,
            onTap: () {},
          ),
          const Divider(indent: 72, endIndent: 20),
          _settingsTile(
            context: context,
            icon: Icons.help_outline_rounded,
            title: l10n.contactSupport,
            colorScheme: colorScheme,
            onTap: () {},
          ),

          // Sign Out
          _sectionHeader(context, ''),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: OutlinedButton.icon(
              onPressed: () => _confirmSignOut(context, l10n),
              icon: const Icon(Icons.logout_rounded, color: AppColors.error),
              label: Text(
                l10n.signOut,
                style: const TextStyle(color: AppColors.error),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    if (title.isEmpty) return const SizedBox(height: 8);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _settingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required ColorScheme colorScheme,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: colorScheme.primary),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: trailing ??
          (onTap != null
              ? Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: colorScheme.onSurfaceVariant,
                )
              : null),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  String _themeLabel(ThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ThemeMode.light:
        return l10n.lightMode;
      case ThemeMode.dark:
        return l10n.darkMode;
      case ThemeMode.system:
        return l10n.systemTheme;
    }
  }

  Widget _themeIcon(ThemeMode mode) {
    final icons = {
      ThemeMode.light: Icons.light_mode_rounded,
      ThemeMode.dark: Icons.dark_mode_rounded,
      ThemeMode.system: Icons.brightness_auto_rounded,
    };
    return Icon(icons[mode] ?? Icons.brightness_auto_rounded);
  }

  String _languageName(String code) {
    return AppConstants.supportedLanguages.firstWhere(
      (l) => l['code'] == code,
      orElse: () => {'nativeName': 'English'},
    )['nativeName'] ?? 'English';
  }

  String _languageFlag(String code) {
    return AppConstants.supportedLanguages.firstWhere(
      (l) => l['code'] == code,
      orElse: () => {'flag': '🌐'},
    )['flag'] ?? '🌐';
  }

  void _showThemeDialog(BuildContext context, AppLocalizations l10n, ThemeMode current) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Theme', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ...ThemeMode.values.map((mode) {
                return RadioListTile<ThemeMode>(
                  title: Text(_themeLabel(mode, l10n)),
                  secondary: Icon(_themeIcon(mode).icon),
                  value: mode,
                  groupValue: current,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(themeModeProvider.notifier).setThemeMode(value);
                    }
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context, AppLocalizations l10n, String current) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          builder: (_, controller) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.selectLanguage, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    controller: controller,
                    children: AppConstants.supportedLanguages.map((lang) {
                      final isSelected = current == lang['code'];
                      return ListTile(
                        leading: Text(lang['flag']!, style: const TextStyle(fontSize: 28)),
                        title: Text(lang['nativeName']!),
                        subtitle: Text(lang['name']!),
                        trailing: isSelected
                            ? Icon(Icons.check_circle_rounded,
                                color: Theme.of(context).colorScheme.primary)
                            : null,
                        onTap: () {
                          ref.read(localeProvider.notifier).setLocale(lang['code']!);
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCurrencyDialog(BuildContext context, AppLocalizations l10n, CurrencyState state) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          builder: (_, controller) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.selectCurrency, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    controller: controller,
                    children: state.currencies.map((currency) {
                      final isSelected = state.selectedCurrencyCode == currency.code;
                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              currency.symbol,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                              ),
                            ),
                          ),
                        ),
                        title: Text('${currency.code} - ${currency.name}'),
                        trailing: isSelected
                            ? Icon(Icons.check_circle_rounded,
                                color: Theme.of(context).colorScheme.primary)
                            : null,
                        onTap: () {
                          ref.read(currencyProvider.notifier).setCurrency(currency.code);
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmSignOut(BuildContext context, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.signOut),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(authProvider.notifier).logout();
      if (mounted) context.go(AppRoutes.login);
    }
  }
}
