import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme/studlok_theme.dart';
import 'auth_service.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _auth = AuthService.instance;
  bool _loading = false;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _loading = true);
    try {
      await action();
    } on AuthServiceException catch (e) {
      if (!e.userCancelled && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Something went wrong: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ACCOUNT')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: StreamBuilder<AuthState>(
            stream: _auth.authStateChanges,
            builder: (context, _) {
              final user = _auth.currentUser;
              return user == null ? _buildSignedOut() : _buildSignedIn(user);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSignedOut() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'SIGN IN',
          style: TextStyle(color: StudlokColors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 1.1),
        ),
        const SizedBox(height: 8),
        const Text(
          'Sign in to generate quizzes from your own course notes.',
          style: TextStyle(color: StudlokColors.dimWhite, fontSize: 15),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: _loading ? null : () => _run(_auth.signInWithApple),
          icon: const Icon(Icons.apple),
          label: const Text('Sign in with Apple'),
          style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _loading ? null : () => _run(_auth.signInWithGoogle),
          icon: const Icon(Icons.g_mobiledata),
          label: const Text('Sign in with Google'),
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
        ),
        if (_loading) ...[
          const SizedBox(height: 24),
          const Center(child: CircularProgressIndicator(color: StudlokColors.accent)),
        ],
      ],
    );
  }

  Widget _buildSignedIn(User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'ACCOUNT',
          style: TextStyle(color: StudlokColors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 1.1),
        ),
        const SizedBox(height: 8),
        Text(
          user.email ?? 'Signed in',
          style: const TextStyle(color: StudlokColors.dimWhite, fontSize: 15),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _loading ? null : () => _run(_auth.signOut),
          child: const Text('Sign out'),
        ),
      ],
    );
  }
}
