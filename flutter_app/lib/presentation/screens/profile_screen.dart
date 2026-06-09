import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/common/custom_text_field.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final success = await ref.read(authProvider.notifier).updateProfile(
          name: _nameController.text.trim(),
        );
    if (success && mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);
    final authState = ref.watch(authProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (!_isEditing)
            TextButton.icon(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(l10n.edit),
            )
          else
            TextButton(
              onPressed: () => setState(() {
                _isEditing = false;
                final u = ref.read(currentUserProvider);
                _nameController.text = u?.name ?? '';
              }),
              child: Text(l10n.cancel),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryLight.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      user?.initials ?? 'U',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (_isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: colorScheme.background, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(user?.name ?? '', style: Theme.of(context).textTheme.headlineSmall),
            Text(user?.email ?? '', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),

            const SizedBox(height: 32),

            // Form
            CustomTextField(
              controller: _nameController,
              label: l10n.fullName,
              prefixIcon: Icons.person_outline_rounded,
              readOnly: !_isEditing,
              validator: null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _emailController,
              label: l10n.email,
              prefixIcon: Icons.email_outlined,
              readOnly: true,
              validator: null,
            ),

            const SizedBox(height: 16),

            // Verified badge
            if (user?.isVerified == true)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_rounded, color: AppColors.success, size: 16),
                    const SizedBox(width: 6),
                    const Text('Email Verified', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            if (_isEditing)
              CustomButton(
                text: 'Save Changes',
                onPressed: authState.isLoading ? null : _saveProfile,
                isLoading: authState.isLoading,
                width: double.infinity,
                icon: Icons.save_rounded,
              ),

            // Stats
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _statCard(context, 'Member Since', _formatDate(user?.createdAt), colorScheme)),
                const SizedBox(width: 12),
                Expanded(child: _statCard(context, 'Account Type', user?.role.toUpperCase() ?? 'USER', colorScheme)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(BuildContext context, String label, String value, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(value, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }
}
