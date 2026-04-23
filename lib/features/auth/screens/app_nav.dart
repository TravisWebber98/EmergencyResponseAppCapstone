import 'package:flutter/material.dart';

import 'notifications.dart';
import 'home.dart';
import 'profile.dart';

class AppNav extends StatefulWidget {
  const AppNav({super.key});

  @override
  State<AppNav> createState() => _AppNavState();
}

class _AppNavState extends State<AppNav> {
  int currentPageIndex = 1;

  @override
  Widget build(BuildContext context){
    final pages =[
      const NotificationsPage(),
      const HomePage(),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("App Testing")),
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
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],

      ),
      body: pages[currentPageIndex],
    );
  }
}