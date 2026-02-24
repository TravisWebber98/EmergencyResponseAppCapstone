import 'package:flutter/material.dart';
import 'package:emergency_response_app/features/auth/auth_screens.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // You can keep "home:" if you want, but routes make navigation cleaner.
      initialRoute: '/login',
      routes: {
        '/login': (context) => const loginPage(),
        '/register': (context) => const registerPage(),
        '/app': (context) => const AppNav(),
        '/chat': (context) => const CommPage(),
        '/edit-profile': (context) => const editProfilePage(),
      },
    );
  }
}