import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../core/providers/theme_service_provider.dart';
import '../../../../theme/style_guide.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeServiceProvider);
    final bool isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Settings',
          style: AppTypography.textMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        children: [
          _settingsTile(
            context,
            icon: Icons.notifications_none_rounded,
            title: 'Notification',
            onTap: () {},
          ),
          _settingsTile(
            context,
            icon: Icons.lock_outline_rounded,
            title: 'Security',
            onTap: () {},
          ),
          _settingsTile(
            context,
            icon: Icons.help_outline_rounded,
            title: 'Help',
            onTap: () {},
          ),
          SwitchListTile(
            value: isDark,
            onChanged: (value) {
              ref.read(themeServiceProvider.notifier).setDarkMode(value);
            },
            secondary: const Icon(Icons.dark_mode_outlined),
            title: Text(
              'Dark Mode',
              style: AppTypography.textMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            activeColor: AppColors.primaryDefault,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: Text(
              'Logout',
              style: AppTypography.textMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            onTap: () => _confirmLogout(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _settingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: AppTypography.textMedium.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryDefault,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    await ref.read(authRepositoryProvider).signOut();

    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}
