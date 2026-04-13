import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emergency_response_app/features/auth/auth_screens.dart';
import 'package:emergency_response_app/features/community/community_screens.dart';
import 'package:emergency_response_app/repositories/community/firebase_community_repository.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final communityRepository = FirebaseCommunityRepository(
      firestore: FirebaseFirestore.instance,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const loginPage(),
        '/register': (context) => const registerPage(),
        '/app': (context) => const AppNav(),
        '/chat': (context) => CommPage(
          repository: communityRepository,
        ),
        '/edit-profile': (context) => const editProfilePage(),
      },
    );
  }
}