import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'edit_profile.dart';


class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    // required this.name,
    // required this.phoneNumber,
    // required this.address,
    // required this.city,
    // required this.state,
    // required this.zipcode,
    // required this.email,
  });

  // final String name;
  // final String phoneNumber;
  // final String address;
  // final String city;
  // final String state;
  // final String zipcode;
  // final String email;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('accounts').doc(user!.uid)
        .snapshots(), builder: (context, snap){
          final data = snap.data?.data() ?? {};
          
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text('Profile', style: theme.textTheme.titleLarge),
              const SizedBox(height: 20),
              Text('Display Name: ${data['display'] ?? ''}', style: theme.textTheme.bodyLarge),
              // commented out until location can be saved, no initial way of obtaining location
              const SizedBox(height: 20),
              Text('Business Name: ${data['businessName'] ?? ''}', style: theme.textTheme.bodyLarge),
              const SizedBox(height: 20),
              Text('Location: ${data['city'] ?? ''} , ${data['state'] ?? ''} , ${data['country'] ?? ''}', style: theme.textTheme.bodyLarge),
              const SizedBox(height: 20),
              Text('Email: ${data['email'] ?? ''}', style: theme.textTheme.bodyLarge),
              const SizedBox(height: 20),
              Text('Phone: ${data['phone'] ?? ''}', style: theme.textTheme.bodyLarge),
              const SizedBox(height: 20),
              const SizedBox(width: double.infinity),

              SizedBox(
                height: 65,
                width: 360,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.lightBlue,
                    ),
                    onPressed: () {
                      Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const editProfilePage()));
                    },
                    child: const Text(
                      'Edit',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: 65,
                width: 360,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.grey[200],
                    ),
                    onPressed: () async{
                      await FirebaseAuth.instance.signOut();
                      if (!context.mounted) return;

                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (_) => false,
                      );
                    },
                    child: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  ),
                ),        
              ),
            ],
          );
        },
    );
  }
}
