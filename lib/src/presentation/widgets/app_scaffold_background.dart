import 'package:flutter/material.dart';

class AppScaffoldBackground extends StatelessWidget {
  const AppScaffoldBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF7F0E8), Color(0xFFF3E3CC)],
        ),
      ),
      child: child,
    );
  }
}
