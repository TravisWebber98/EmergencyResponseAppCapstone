import 'package:flutter/material.dart';

import 'community_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Colors.transparent,
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Card(
            child: ListTile(
              leading: const Icon(Icons.pin_drop),
              title: const Text('Chat for: ____'),
              subtitle: const Text('latest pinned message'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CommPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}