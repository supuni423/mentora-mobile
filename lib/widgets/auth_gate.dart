import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';

/// Shown in place of an auth-required tab/section when the student isn't
/// logged in, instead of every screen special-casing "not authenticated".
class AuthGate extends StatelessWidget {
  const AuthGate({super.key, this.message = 'Log in to continue'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const LoginScreen())),
              child: const Text('Log In'),
            ),
          ],
        ),
      ),
    );
  }
}
