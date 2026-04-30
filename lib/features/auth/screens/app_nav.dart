import 'package:emergency_response_app/features/community/community_screens.dart';
import 'package:emergency_response_app/repositories/community/community_repository.dart';
import 'package:flutter/material.dart';
import 'package:emergency_response_app/repositories/community/firebase_community_repository.dart';
import 'package:emergency_response_app/features/messaging/screens/messaging_page.dart';
import 'package:emergency_response_app/features/community/screens/community_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emergency_response_app/repositories/community/community_repository.dart';

import 'notifications.dart';
import 'home.dart';
import 'profile.dart';

class AppNav extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const AppNav({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<AppNav> createState() => _AppNavState();
}

class _AppNavState extends State<AppNav> {
  int currentPageIndex = 1;

  @override
  Widget build(BuildContext context){
    final pages =[
      const NotificationsPage(),
      // const HomePage(),
      CommPage(
        repository: FirebaseCommunityRepository(
          firestore: FirebaseFirestore.instance,
        ),
      ),
      const MessagingPage(),
      ProfilePage(
        isDarkMode: widget.isDarkMode,
        onThemeChanged: widget.onThemeChanged,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          
          title: Row (
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/logo.png', height: 30),
            const SizedBox(width: 10),
            const Text("- ERA"),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(

        selectedIndex: currentPageIndex,
        onDestinationSelected: (i) => setState(()
        => currentPageIndex = i
        ),

        indicatorColor: const Color.fromARGB(255, 164, 183, 231),

        destinations: const <Widget>[
          NavigationDestination(
            icon: Badge(child: Icon(Icons.notifications_sharp)),
            label: 'Notifications',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],

      ),
      body: pages[currentPageIndex],
    );
  }
}