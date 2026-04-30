import 'package:flutter/material.dart';

class FormSection extends StatelessWidget {
  final Widget child;

  const FormSection({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: child,
    );
  }
}