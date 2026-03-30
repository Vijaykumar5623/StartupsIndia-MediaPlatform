import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/style_guide.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.grayscaleWhite,
      appBar: AppBar(
        title: Text(
          'Home',
          style: AppTypography.displaySmallBold.copyWith(
            color: AppColors.grayscaleTitleActive,
          ),
        ),
        backgroundColor: AppColors.grayscaleWhite,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome to the Dashboard',
              style: AppTypography.textLarge.copyWith(
                color: AppColors.grayscaleBodyText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // ── DEBUG SECTION ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFCC00), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.bug_report, color: Color(0xFFB38600), size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Debug Info',
                        style: AppTypography.textSmall.copyWith(
                          color: const Color(0xFFB38600),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _DebugRow(
                    label: 'Email',
                    value: user?.email ?? '— not signed in —',
                  ),
                  const SizedBox(height: 8),
                  _DebugRow(
                    label: 'UID',
                    value: user?.uid ?? '— not signed in —',
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final authRepo = ref.read(authRepositoryProvider);
                        await authRepo.signOut();
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            (route) => false,
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.errorDark,
                        side: const BorderSide(color: AppColors.errorDark),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      icon: const Icon(Icons.logout, size: 18),
                      label: Text(
                        'Sign Out',
                        style: AppTypography.linkMedium.copyWith(
                          color: AppColors.errorDark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ── END DEBUG SECTION ────────────────────────────────────────────
          ],
        ),
      ),
    );
  }
}

/// A small label + value row used inside the debug panel.
class _DebugRow extends StatelessWidget {
  final String label;
  final String value;

  const _DebugRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 52,
          child: Text(
            '$label:',
            style: AppTypography.textSmall.copyWith(
              color: AppColors.grayscaleTitleActive,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: AppTypography.textSmall.copyWith(
              color: AppColors.grayscaleBodyText,
            ),
          ),
        ),
      ],
    );
  }
}
