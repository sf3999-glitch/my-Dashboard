import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/currency_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final currencyState = ref.watch(currencyProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _SectionHeader('Appearance'),
          _SettingsTile(
            icon: Icons.palette_outlined,
            title: 'Theme',
            subtitle: themeMode == ThemeMode.dark ? 'Dark' : themeMode == ThemeMode.light ? 'Light' : 'System Default',
            trailing: DropdownButton<ThemeMode>(
              value: themeMode,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
              ],
              onChanged: (mode) {
                if (mode != null) ref.read(themeModeProvider.notifier).setThemeMode(mode);
              },
            ),
          ),
          const Divider(height: 1),

          _SectionHeader('Language & Region'),
          _SettingsTile(
            icon: Icons.language_outlined,
            title: 'Language',
            subtitle: AppConstants.supportedLanguages.firstWhere((l) => l['code'] == locale.languageCode, orElse: () => {'nativeName': 'English'})['nativeName'] ?? 'English',
            onTap: () => _showLanguagePicker(context, ref, locale),
          ),
          const Divider(height: 1),
          _SettingsTile(
            icon: Icons.currency_exchange,
            title: 'Currency',
            subtitle: currencyState.selectedCurrencyCode,
            onTap: () => _showCurrencyPicker(context, ref, currencyState),
          ),
          const Divider(height: 1),

          _SectionHeader('Notifications'),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Push Notifications',
            subtitle: 'Project updates and reports',
            trailing: Switch(value: true, onChanged: (_) {}),
          ),
          const Divider(height: 1),

          _SectionHeader('About'),
          _SettingsTile(
            icon: Icons.info_outlined,
            title: 'Version',
            subtitle: '1.0.0',
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () {},
          ),
          const Divider(height: 1),

          _SectionHeader('Account'),
          _SettingsTile(
            icon: Icons.logout,
            title: 'Sign Out',
            titleColor: colorScheme.error,
            iconColor: colorScheme.error,
            onTap: () => _confirmSignOut(context, ref),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref, dynamic currentLocale) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Select Language', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1),
          ...AppConstants.supportedLanguages.map((lang) => ListTile(
            leading: Text(lang['flag'] ?? '🌐', style: const TextStyle(fontSize: 24)),
            title: Text(lang['nativeName'] ?? ''),
            subtitle: Text(lang['name'] ?? ''),
            trailing: currentLocale.languageCode == lang['code'] ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
            onTap: () {
              ref.read(localeProvider.notifier).setLocale(lang['code']!);
              Navigator.pop(context);
            },
          )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context, WidgetRef ref, dynamic currentState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        maxChildSize: 0.85,
        builder: (ctx, scroll) => Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Select Currency', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: scroll,
                itemCount: currentState.currencies.length,
                itemBuilder: (_, i) {
                  final c = currentState.currencies[i];
                  return ListTile(
                    leading: Text(c.symbol, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    title: Text(c.code),
                    subtitle: Text(c.name),
                    trailing: currentState.selectedCurrencyCode == c.code ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
                    onTap: () {
                      ref.read(currencyProvider.notifier).setCurrency(c.code);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
    child: Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    ),
  );
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;
  final Color? iconColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.titleColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: iconColor ?? Theme.of(context).colorScheme.onSurfaceVariant),
    title: Text(title, style: TextStyle(color: titleColor, fontWeight: FontWeight.w500)),
    subtitle: subtitle != null ? Text(subtitle!) : null,
    trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
    onTap: onTap,
  );
}

// Need to import AppConstants
class AppConstants {
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English', 'nativeName': 'English', 'flag': '🇺🇸'},
    {'code': 'ar', 'name': 'Arabic', 'nativeName': 'العربية', 'flag': '🇸🇦'},
    {'code': 'es', 'name': 'Spanish', 'nativeName': 'Español', 'flag': '🇪🇸'},
    {'code': 'fr', 'name': 'French', 'nativeName': 'Français', 'flag': '🇫🇷'},
    {'code': 'zh', 'name': 'Chinese', 'nativeName': '中文', 'flag': '🇨🇳'},
    {'code': 'hi', 'name': 'Hindi', 'nativeName': 'हिन्दी', 'flag': '🇮🇳'},
    {'code': 'ur', 'name': 'Urdu', 'nativeName': 'اردو', 'flag': '🇵🇰'},
  ];
}
