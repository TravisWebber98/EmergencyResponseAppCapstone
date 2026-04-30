import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'app_nav.dart';
import 'login.dart';

//Decides which screen to show on app launch (and after sign-in/sign-out)
// by listening to Firebase Auth's session state.
//
// Firebase Auth caches the signed-in user on disk by default, so on the
// second launch `authStateChanges()` re-emits that user as soon as the
// SDK is ready. That means after the first successful login, returning
// users land in the app without having to type their password again,
// until they explicitly sign out (or the session expires server-side).
class AuthGate extends StatelessWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;
  const AuthGate({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,  
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        //First emission can be slightly delayed while the SDK reads the
        //cached token — show a tiny splash so we don't flash the login
        //screen at users who are actually already signed in.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const loginPage();
        }
        return AppNav(
          isDarkMode: false,
          onThemeChanged: (value) {},
        );
      },
    );
  }
}
