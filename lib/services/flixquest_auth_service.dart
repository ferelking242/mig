import 'auth_session_controller.dart';

class FlixQuestAuthService {
  Future<LocalUserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.toLowerCase().trim();
    if (normalizedEmail.isEmpty || password.trim().isEmpty) {
      throw const LocalAuthException(
        'invalid-credential',
        'Enter an email and password.',
      );
    }
    final user = LocalUser(
      uid: _localId(normalizedEmail),
      email: normalizedEmail,
      displayName: normalizedEmail.split('@').first,
    );
    _setUser(user);
    return LocalUserCredential(user);
  }

  Future<LocalUserCredential> signInAnonymously() async {
    final user = LocalUser(
      uid: 'guest-local',
      displayName: 'Guest',
      isAnonymous: true,
    );
    _setUser(user);
    return LocalUserCredential(user);
  }

  Future<LocalUserCredential> signInWithGoogle() async {
    final user = LocalUser(
      uid: 'google-local',
      email: 'google@local',
      displayName: 'Google user',
    );
    _setUser(user);
    return LocalUserCredential(user);
  }

  static Future<void> signOutGoogle() async {
    // Kept for existing screen actions; there is no external provider now.
  }

  Future<LocalUserCredential> createAccount({
    required String fullName,
    required String email,
    required String username,
    required String password,
    required int profileId,
    bool verified = false,
  }) async {
    final normalizedUsername = username.toLowerCase().trim();
    if (normalizedUsername.isEmpty) {
      throw const LocalAuthException(
        'username-already-in-use',
        'Enter a username.',
      );
    }
    final normalizedEmail = email.toLowerCase().trim();
    final user = LocalUser(
      uid: _localId(normalizedEmail),
      email: normalizedEmail,
      displayName: fullName.trim(),
    );
    _setUser(user);
    return LocalUserCredential(user);
  }

  LocalUser? get currentUser => AuthSessionController.instance.currentUser;

  Future<void> signOut() async {
    AuthSessionController.instance.setAuthenticatedUser(null);
  }

  Future<void> deleteCurrentUser() async {
    await signOut();
  }

  void _setUser(LocalUser user) {
    AuthSessionController.instance.setAuthenticatedUser(user);
  }

  String _localId(String value) {
    final normalized = value.replaceAll(RegExp(r'[^a-z0-9]'), '');
    return 'local-${normalized.isEmpty ? 'user' : normalized}';
  }
}
