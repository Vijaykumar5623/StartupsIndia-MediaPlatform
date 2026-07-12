import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/app_text_field.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../../core/utils/password_validator.dart';
import '../../../../theme/style_guide.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Lets a user manage how they sign in: email/password and a linked Google
/// account. Either can be used to sign into the same account.
class SignInMethodsScreen extends ConsumerStatefulWidget {
  const SignInMethodsScreen({super.key});

  @override
  ConsumerState<SignInMethodsScreen> createState() =>
      _SignInMethodsScreenState();
}

class _SignInMethodsScreenState extends ConsumerState<SignInMethodsScreen> {
  bool _busy = false;

  User? get _user => ref.read(authRepositoryProvider).currentUser;

  List<String> get _providerIds =>
      ref.read(authRepositoryProvider).linkedProviderIds;

  bool get _hasPassword => _providerIds.contains('password');
  bool get _hasGoogle => _providerIds.contains('google.com');

  String get _accountEmail => _user?.email ?? '';

  String get _googleEmail {
    final data = _user?.providerData
        .where((p) => p.providerId == 'google.com')
        .toList();
    return (data == null || data.isEmpty) ? '' : (data.first.email ?? '');
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      await _user?.reload();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _connectGoogle() async {
    await _run(() async {
      try {
        final result = await ref.read(authRepositoryProvider).linkGoogle();
        if (result == null) return; // cancelled
        _snack('Google account connected.');
      } on FirebaseAuthException catch (e) {
        _snack(_linkError(e.code, 'Google'));
      } catch (_) {
        _snack('Could not connect Google. Please try again.');
      }
    });
  }

  Future<void> _addPassword() async {
    final password = await _promptForPassword();
    if (password == null) return;
    await _run(() async {
      try {
        await ref
            .read(authRepositoryProvider)
            .linkEmailPassword(email: _accountEmail, password: password);
        _snack('Password added. You can now sign in with your email.');
      } on FirebaseAuthException catch (e) {
        _snack(_linkError(e.code, 'email'));
      } catch (_) {
        _snack('Could not add a password. Please try again.');
      }
    });
  }

  Future<void> _disconnect(String providerId, String label) async {
    if (_providerIds.length <= 1) {
      _snack('You need at least one sign-in method.');
      return;
    }
    final confirmed = await _confirmDisconnect(label);
    if (confirmed != true) return;
    await _run(() async {
      try {
        await ref.read(authRepositoryProvider).unlinkProvider(providerId);
        _snack('$label disconnected.');
      } on FirebaseAuthException catch (e) {
        _snack(
          e.code == 'requires-recent-login'
              ? 'Please log out and back in, then try again.'
              : 'Could not disconnect $label. Please try again.',
        );
      }
    });
  }

  String _linkError(String code, String what) {
    switch (code) {
      case 'credential-already-in-use':
      case 'email-already-in-use':
        return 'That $what is already linked to another StartupsIndia account.';
      case 'provider-already-linked':
        return 'That method is already connected.';
      case 'requires-recent-login':
        return 'Please log out and back in, then try again.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Those credentials could not be verified.';
      default:
        return 'Could not connect $what. Please try again.';
    }
  }

  Future<bool?> _confirmDisconnect(String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.grayscaleWhite,
        title: Text(
          'Disconnect $label?',
          style: AppTypography.textSmall.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.grayscaleTitleActive,
          ),
        ),
        content: Text(
          "You won't be able to sign in with $label anymore.",
          style: AppTypography.textSmall.copyWith(
            fontSize: 13,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.grayscaleBodyText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Disconnect',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _promptForPassword() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.grayscaleWhite,
        title: Text(
          'Add a password',
          style: AppTypography.textSmall.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.grayscaleTitleActive,
          ),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Set a password for $_accountEmail so you can also sign in with '
                'your email.',
                style: AppTypography.textSmall.copyWith(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.grayscaleBodyText,
                ),
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: controller,
                label: 'New Password',
                hintText: 'Min 8 chars, 1 upper, 1 number, 1 symbol',
                isPassword: true,
                validator: validateStrongPassword,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, controller.text);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // ── UI ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Watch auth state so the screen rebuilds after link/unlink.
    ref.watch(authStateChangesProvider);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.grayscaleSecondaryButton,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _infoCard(isDark),
                    const SizedBox(height: 20),
                    _sectionLabel('YOUR SIGN-IN METHODS', isDark),
                    const SizedBox(height: 8),
                    _methodCard(
                      isDark: isDark,
                      icon: Icons.email_outlined,
                      iconColor: AppColors.primaryDefault,
                      title: 'Email & Password',
                      subtitle: _hasPassword
                          ? _accountEmail
                          : 'Not set — add one to sign in with email',
                      connected: _hasPassword,
                      onAction: _hasPassword
                          ? () => _disconnect('password', 'Email & Password')
                          : _addPassword,
                      actionLabel: _hasPassword ? 'Remove' : 'Add',
                    ),
                    const SizedBox(height: 12),
                    _methodCard(
                      isDark: isDark,
                      icon: Icons.g_mobiledata_rounded,
                      iconColor: const Color(0xFF4285F4),
                      title: 'Google',
                      subtitle: _hasGoogle
                          ? (_googleEmail.isEmpty ? 'Connected' : _googleEmail)
                          : 'Not connected',
                      connected: _hasGoogle,
                      onAction: _hasGoogle
                          ? () => _disconnect('google.com', 'Google')
                          : _connectGoogle,
                      actionLabel: _hasGoogle ? 'Remove' : 'Connect',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.grayscaleWhite;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.grayscaleLine;
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.grayscaleTitleActive;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: _busy ? null : () => Navigator.of(context).maybePop(),
            icon: Icon(Icons.arrow_back_rounded, color: textColor, size: 22),
          ),
          Expanded(
            child: Text(
              'Sign-in Methods',
              textAlign: TextAlign.center,
              style: AppTypography.textSmall.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _infoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryDefault.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryDefault.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.primaryDefault,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Connect more than one way to sign in. Any connected method logs '
              'you into this same account.',
              style: AppTypography.textSmall.copyWith(
                fontSize: 12,
                color: AppColors.primaryDefault,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: AppTypography.textSmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.grayscaleBodyText,
        ),
      ),
    );
  }

  Widget _methodCard({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool connected,
    required VoidCallback onAction,
    required String actionLabel,
  }) {
    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.grayscaleTitleActive;
    final subColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.grayscaleBodyText;
    final isRemove = actionLabel == 'Remove';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.grayscaleWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.grayscaleLine,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: AppTypography.textSmall.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (connected) _connectedBadge(),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.textSmall.copyWith(
                    fontSize: 12,
                    color: subColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: _busy ? null : onAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: const Size(0, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel,
              style: AppTypography.textSmall.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isRemove
                    ? const Color(0xFFEF4444)
                    : AppColors.primaryDefault,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _connectedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.successDefault.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 11,
            color: AppColors.successDefault,
          ),
          const SizedBox(width: 3),
          Text(
            'Connected',
            style: AppTypography.textSmall.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.successDefault,
            ),
          ),
        ],
      ),
    );
  }
}
