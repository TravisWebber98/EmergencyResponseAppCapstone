import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emergency_response_app/features/auth/auth_screens.dart';
import 'package:emergency_response_app/features/auth/screens/auth_gate.dart';
import 'package:emergency_response_app/features/community/community_screens.dart';
import 'package:emergency_response_app/repositories/community/firebase_community_repository.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //default to dark mode (can be toggled in profile settings)
  bool isDarkMode = true;
  void toggleTheme(bool value) {
    setState(() {
      isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final communityRepository = FirebaseCommunityRepository(
      firestore: FirebaseFirestore.instance,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //theme
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      // AuthGate inspects Firebase Auth on launch and routes to AppNav if a
      // session is cached, or login otherwise. Existing pushNamed targets
      // (like '/login' on logout) still work via the routes map below.
      home: AuthGate(
        isDarkMode: isDarkMode,
        onThemeChanged: toggleTheme,
      ),
      routes: {
        '/login': (context) => const loginPage(),
        '/register': (context) => const registerPage(),
        '/app': (context) => AppNav(
          isDarkMode: isDarkMode,
          onThemeChanged: toggleTheme,
        ),
        '/chat': (context) => CommPage(
          repository: communityRepository,
        ),
        '/edit-profile': (context) => const editProfilePage(),
      },
    );
  }
}