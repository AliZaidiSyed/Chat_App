
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/features/auth/providers/google_auth_provider.dart';
import 'package:chat_app/core/widgets/app_snackbar.dart';

class GoogleLoginScreen extends ConsumerWidget {
  const GoogleLoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(googleAuthProvider);
    final authNotifier = ref.read(googleAuthProvider.notifier);

    ref.listen(googleAuthProvider, (previous, next) {
      if (next.error != null && previous?.error != next.error) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;

          showAppSnackbar(
            description: next.error ?? "Something went wrong",
            context: context,
            type: SnackbarType.error,
          );

          ref.read(googleAuthProvider.notifier).clearError();
        });
      }
    });

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: authState.isLoading
            ? null
            : () {
          authNotifier.clearError();
          authNotifier.signInWithGoogle();
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0F172A),
          side: const BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: authState.isLoading
            ? const SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF2563EB),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "assets/images/search.png",
              height: 24,
              width: 24,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            const Text(
              "Continue with Google",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
