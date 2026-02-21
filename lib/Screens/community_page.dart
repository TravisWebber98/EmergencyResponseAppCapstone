import 'package:flutter/material.dart';

class CommPage extends StatelessWidget {
  const CommPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('-location- page')),
      body: const Center(
        child: Text('Community page content here'),
      ),
    );
  }
}