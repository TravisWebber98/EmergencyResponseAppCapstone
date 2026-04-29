import 'package:flutter/material.dart';
import 'package:emergency_response_app/features/auth/auth_screens.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = true;

  void toggleTheme(bool value) {
    setState(() {
      isDarkMode = value;
    });
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      
      //theme
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // You can keep "home:" if you want, but routes make navigation cleaner.
      initialRoute: '/login',
      routes: {
        '/login': (context) => const loginPage(),
        '/register': (context) => const registerPage(),
        '/app': (context) =>  AppNav(
          isDarkMode: isDarkMode,
          onThemeChanged: toggleTheme,
        ),
        '/chat': (context) => const CommPage(),
        '/edit-profile': (context) => const editProfilePage(),
      },
    );
  }
}