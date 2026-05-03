import 'package:flutter/material.dart';

class ProfileInfo extends StatelessWidget{
  final String title;
  final String value;

  const ProfileInfo({super.key, 
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}