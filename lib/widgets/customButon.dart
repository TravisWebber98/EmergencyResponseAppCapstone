import 'package:flutter/material.dart';

class Custombuton extends StatelessWidget{
  final String text;
  final VoidCallback onPressed;
  final bool secondaryStyle;

  const Custombuton({
    required this.text,
    required this.onPressed,
    this.secondaryStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: secondaryStyle ? Colors.grey[300] : Colors.blue,
        foregroundColor: secondaryStyle ? Colors.grey[200] : Colors.lightBlue,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: secondaryStyle ? TextStyle(color: Colors.black, fontSize: 20): TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }
}