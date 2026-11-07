import 'package:chat_app/services//google_auth_service.dart';
import 'package:flutter_riverpod/legacy.dart';

class GoogleAuthState {
  final bool isLoading;
  final String? error;

  const GoogleAuthState({
    this.isLoading = false,
    this.error,
  });
}

class GoogleAuthNotifier extends StateNotifier<GoogleAuthState> {
  final FirebaseServices _googleAuthMethod;

  GoogleAuthNotifier(this._googleAuthMethod)
      : super(const GoogleAuthState());

  void clearError() {
    state = GoogleAuthState(isLoading: state.isLoading);
  }

  Future<void> signInWithGoogle() async {
    if (state.isLoading) return;

    state = const GoogleAuthState(isLoading: true);

    try {
      final result = await _googleAuthMethod.signInWithGoogle();

      if (!mounted) return;

      state = GoogleAuthState(
        error: result == "success" ? null : result,
      );
    } catch (e) {
      if (!mounted) return;

      state = GoogleAuthState(error: e.toString());
    }
  }
}

final googleAuthProvider =
StateNotifierProvider<GoogleAuthNotifier, GoogleAuthState>((ref) {
  return GoogleAuthNotifier(
    ref.watch(googleAuthMethodProvider),
  );
});