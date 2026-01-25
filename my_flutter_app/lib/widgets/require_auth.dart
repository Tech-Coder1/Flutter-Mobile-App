import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/login_screen.dart';

class RequireAuth extends StatelessWidget {
  final Widget child;
  const RequireAuth({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user == null) {
          // Show login screen with same look; no redesign
          return const LoginScreen();
        }
        return child;
      },
    );
  }
}
