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

  /// Permanently deletes the account server-side (the delete-account edge
  /// function: uploaded files, then the auth user itself, which cascades to
  /// every DB row tied to it — see supabase/functions/delete-account).
  /// Signs out locally afterward so the client reflects it immediately
  /// rather than waiting for the next request to fail with an invalid
  /// session.
  Future<void> deleteAccount() async {
    try {
      await _client.functions.invoke('delete-account');
    } on FunctionException catch (e) {
      throw AuthServiceException(_deleteAccountMessageFor(e));
    } catch (_) {
      throw const AuthServiceException("Couldn't reach the server. Check your connection and try again.");
    }
    await _client.auth.signOut();
  }

  String _deleteAccountMessageFor(FunctionException e) {
    final details = e.details;
    if (details is Map && details['error'] is String) {
      return details['error'] as String;
    }
    switch (e.status) {
      case 0:
        return "Couldn't reach the server. Check your connection and try again.";
      case 401:
        return 'Your session expired — sign in again, then retry.';
      default:
        return "Couldn't delete your account. Try again.";
    }
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
