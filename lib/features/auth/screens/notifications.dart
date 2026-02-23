import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications_sharp),
              title: const Text('Notification Title'),
              subtitle: const Text('Text for Notification here!!'),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}