import 'package:flutter/material.dart';

import 'edit_profile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    required this.name,
    required this.phoneNumber,
    required this.address,
    required this.city,
    required this.state,
    required this.zipcode,
    required this.email,
  });

  final String name;
  final String phoneNumber;
  final String address;
  final String city;
  final String state;
  final String zipcode;
  final String email;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shadowColor: Colors.transparent,
      margin: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Text('Profile', style: theme.textTheme.titleLarge),
          const SizedBox(height: 20),
          Text('Name: $name', style: theme.textTheme.bodyLarge),
          const SizedBox(height: 20),
          Text('Address: $address', style: theme.textTheme.bodyLarge),
          const SizedBox(height: 20),
          Text('$city, $state; $zipcode', style: theme.textTheme.bodyLarge),
          const SizedBox(height: 20),
          Text('Phone: $phoneNumber', style: theme.textTheme.bodyLarge),
          const SizedBox(height: 20),
          Text('email: $email', style: theme.textTheme.bodyLarge),
          const SizedBox(height: 20),
          const SizedBox(width: double.infinity),

          SizedBox(
              height: 65,
              width: 360,
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.lightBlue,
                    ),
                    onPressed: () {
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const editProfilePage()),
                      );
                    },
                    child: const Text(
                      'Edit',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),



          SizedBox(
              height: 65,
              width: 360,
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.grey[200],
                    ),
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                      );
                    },
                    child: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),

        ],
      ),
    );
  }
}