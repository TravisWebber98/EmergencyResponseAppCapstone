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

  // These used to be globals in your old main.dart.
  // Keeping them here makes them easy to pass into ProfilePage.
  String name = "Guest User";
  String phoneNumber = "123-456-7890";
  String address = "123 Sample St.";
  String city = "__city__";
  String state = "XX";
  String zipcode = "12345";
  String email = "sample@email.com";

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const NotificationsPage(),
      const HomePage(),
      ProfilePage(
        name: name,
        phoneNumber: phoneNumber,
        address: address,
        city: city,
        state: state,
        zipcode: zipcode,
        email: email,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("App Testing")),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: const Color.fromARGB(255, 164, 183, 231),
        selectedIndex: currentPageIndex,
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