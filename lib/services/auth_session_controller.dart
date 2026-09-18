import 'dart:async';

import 'package:flutter/foundation.dart';

class LocalUser {
  const LocalUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.isAnonymous = false,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final bool isAnonymous;
}

class LocalUserCredential {
  const LocalUserCredential(this.user);

  final LocalUser? user;
}

class LocalAuthException implements Exception {
  const LocalAuthException(this.code, [this.message]);

  final String code;
  final String? message;
}

/// App-wide local authentication state used by the root presentation gate.
class AuthSessionController {
  AuthSessionController._();

  static final AuthSessionController instance = AuthSessionController._();

  final ValueNotifier<String?> userId = ValueNotifier<String?>(null);
  LocalUser? _currentUser;

  LocalUser? get currentUser => _currentUser;

  void initialize() {
    // Authentication is intentionally local-only in the visual build.
  }

  void setAuthenticatedUser(LocalUser? user) {
    _currentUser = user;
    userId.value = user?.uid;
  }

  void setAuthenticatedUserId(String? value) {
    if (value == null) {
      setAuthenticatedUser(null);
    } else {
      setAuthenticatedUser(
        LocalUser(uid: value, isAnonymous: false),
      );
    }
  }
}
