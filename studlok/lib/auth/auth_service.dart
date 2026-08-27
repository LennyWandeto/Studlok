import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_config.dart';

/// Wraps Supabase auth with native Apple/Google sign-in. Both providers hand
/// Supabase a platform-issued ID token rather than going through a browser
/// redirect — Supabase verifies it directly (see the Authorized Client IDs
/// configured for each provider in the Supabase dashboard).
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  SupabaseClient get _client => Supabase.instance.client;
  bool _googleInitialized = false;

  User? get currentUser => _client.auth.currentUser;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await GoogleSignIn.instance.initialize(
      clientId: AuthConfig.googleIosClientId,
      serverClientId: AuthConfig.googleWebClientId,
    );
    _googleInitialized = true;
  }

  Future<void> signInWithApple() async {
    final rawNonce = generateNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final AuthorizationCredentialAppleID credential;
    try {
      credential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
        nonce: hashedNonce,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const AuthServiceException('Sign-in cancelled.', userCancelled: true);
      }
      throw AuthServiceException('Apple sign-in failed: ${e.message}');
    }

    final idToken = credential.identityToken;
    if (idToken == null) {
      throw const AuthServiceException('Apple did not return an identity token.');
    }

    await _client.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
      nonce: rawNonce,
    );
  }

  Future<void> signInWithGoogle() async {
    await _ensureGoogleInitialized();

    final GoogleSignInAccount account;
    try {
      account = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthServiceException('Sign-in cancelled.', userCancelled: true);
      }
      throw AuthServiceException('Google sign-in failed: ${e.description ?? e.code}');
    }

    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw const AuthServiceException('Google did not return an identity token.');
    }

    await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}

/// A user-facing auth failure, distinct from raw network/Supabase errors so
/// the UI can show [message] directly. [userCancelled] marks flows the user
/// backed out of themselves — those shouldn't surface as an error message.
class AuthServiceException implements Exception {
  const AuthServiceException(this.message, {this.userCancelled = false});

  final String message;
  final bool userCancelled;

  @override
  String toString() => message;
}
