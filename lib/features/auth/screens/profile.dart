import 'package:emergency_response_app/widgets/ProfileInfo.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'edit_profile.dart';


class ProfilePage extends StatelessWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const ProfilePage({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  String formatPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) return '';
    // Remove anything that isn't a digit
    final digits = phone.replaceAll(RegExp(r'\D'), '');

    if (digits.length != 10) return phone; // fallback if invalid

    return '(${digits.substring(0, 3)}) '
        '${digits.substring(3, 6)}-'
        '${digits.substring(6)}';
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('accounts').doc(user!.uid)
          .snapshots(), builder: (context, snap){
      // Show a loading spinner on the very first frame so we don't
      // render with an empty map (which previously caused a red error
      // screen when null fields were passed to formatters).
      if (snap.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snap.hasError) {
        return Center(child: Text('Error loading profile: ${snap.error}'));
      }
      final data = snap.data?.data() ?? {};

      return SingleChildScrollView(
        child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
              const SizedBox(width: 10),
              Switch(
                value: isDarkMode,
                onChanged: onThemeChanged,
              ),  
            ],
          ),

          const SizedBox(height: 90),
          Text(data['display'] ?? '', style: theme.textTheme.titleLarge),
          const SizedBox(height: 10),

          // ProfileInfo(title: 'Display Name', value: data['display'] ?? ''),
          // Text('Display Name: ${data['display'] ?? ''}', style: theme.textTheme.bodyLarge),
          // commented out until location can be saved, no initial way of obtaining location
          // const SizedBox(height: 20),

          if (data['businessName'] != null && data['businessName'].toString().trim().isNotEmpty)
            ProfileInfo(
              title: 'Business Name',
              value: data['businessName'],
            ),
          if (data['businessName'] != null && data['businessName'].toString().trim().isNotEmpty)
            const SizedBox(height: 10),


          ProfileInfo(title: 'Location: ', value: '${data['city'] ?? ''}, ${data['state'] ?? ''}'),
          // Text('Location: ${data['city'] ?? ''}, ${data['state'] ?? ''}', style: theme.textTheme.bodyLarge),
          const SizedBox(height: 10),
          ProfileInfo(title: 'Email: ', value: data['email'] ?? ''),
          // Text('Email: ${data['email'] ?? ''}', style: theme.textTheme.bodyLarge),
          const SizedBox(height: 10),

          ProfileInfo(title: 'Phone: ', value: formatPhoneNumber(data['phone'] as String?)),
          // Text('Phone: ${data['phone'] ?? ''}', style: theme.textTheme.bodyLarge),
          const SizedBox(height: 10),
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
                  backgroundColor: const Color.fromARGB(255, 218, 91, 91),
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
      ),
      );
    },
    );
  }
}