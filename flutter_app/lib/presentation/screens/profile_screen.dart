import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/common/custom_text_field.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _nameCtrl;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final ok = await ref.read(authProvider.notifier).updateProfile(name: _nameCtrl.text.trim());
    if (ok && mounted) setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        actions: [
          if (!_editing)
            IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => setState(() => _editing = true))
          else ...[
            TextButton(onPressed: () => setState(() => _editing = false), child: const Text('Cancel')),
            TextButton(onPressed: _saveProfile, child: const Text('Save')),
          ],
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.primaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.white24,
                        backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
                        child: user?.avatarUrl == null ? Text(user?.name.substring(0, 1).toUpperCase() ?? 'U', style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)) : null,
                      ),
                      if (_editing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: colorScheme.secondary,
                            child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(user?.name ?? 'User', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(user?.email ?? '', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                    child: Text(user?.role ?? 'User', style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Personal Information', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  _editing
                      ? CustomTextField(
                          controller: _nameCtrl,
                          label: 'Full Name',
                          prefixIcon: Icons.person_outlined,
                        )
                      : _InfoRow(label: 'Full Name', value: user?.name ?? '-', icon: Icons.person_outlined),
                  const SizedBox(height: 12),
                  _InfoRow(label: 'Email', value: user?.email ?? '-', icon: Icons.email_outlined),
                  const SizedBox(height: 12),
                  _InfoRow(label: 'Language', value: user?.language?.toUpperCase() ?? 'EN', icon: Icons.language_outlined),
                  const SizedBox(height: 12),
                  _InfoRow(label: 'Currency', value: user?.currency ?? 'USD', icon: Icons.attach_money),
                  const SizedBox(height: 12),
                  _InfoRow(label: 'Member Since', value: user?.createdAt != null ? '${user!.createdAt!.year}' : '-', icon: Icons.calendar_today_outlined),

                  const SizedBox(height: 32),
                  Text('Account Actions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.lock_outlined),
                    label: const Text('Change Password'),
                    style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Delete Account'),
                          content: const Text('This will permanently delete your account and all projects. This cannot be undone.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                            FilledButton(
                              onPressed: () => Navigator.pop(context),
                              style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: Icon(Icons.delete_forever_outlined, color: colorScheme.error),
                    label: Text('Delete Account', style: TextStyle(color: colorScheme.error)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: colorScheme.error),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _InfoRow({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    ),
  );
}
